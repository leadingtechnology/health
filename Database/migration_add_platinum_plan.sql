-- Migration Script: Add Platinum plan and Advanced model tier
-- Date: 2025-09-05
-- Description: Adds new membership tiers to support the updated plan strategy

-- Add new plan type 'platinum' to the enum if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumlabel = 'platinum' 
        AND enumtypid = (
            SELECT oid FROM pg_type WHERE typname = 'plan_type'
        )
    ) THEN
        ALTER TYPE plan_type ADD VALUE 'platinum' AFTER 'pro';
    END IF;
END $$;

-- Add new model tier 'advanced' to the enum if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumlabel = 'advanced' 
        AND enumtypid = (
            SELECT oid FROM pg_type WHERE typname = 'model_tier'
        )
    ) THEN
        ALTER TYPE model_tier ADD VALUE 'advanced' AFTER 'enhanced';
    END IF;
END $$;

-- Add new quota tracking table for advanced features
CREATE TABLE IF NOT EXISTS plan_quotas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quota_type VARCHAR(50) NOT NULL,
    quota_limit INTEGER NOT NULL,
    quota_used INTEGER NOT NULL DEFAULT 0,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, quota_type, period_start)
);

-- Index for efficient quota lookups
CREATE INDEX IF NOT EXISTS idx_plan_quotas_user_period 
ON plan_quotas(user_id, period_start, period_end);

-- Function to check voice quota for platinum users
CREATE OR REPLACE FUNCTION fn_check_voice_quota(
    p_user_id UUID,
    p_minutes INTEGER
) RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    v_plan plan_type;
    v_daily_used INTEGER;
    v_monthly_used INTEGER;
BEGIN
    -- Get user plan
    SELECT plan INTO v_plan FROM users WHERE id = p_user_id;
    
    -- Only check for platinum users
    IF v_plan != 'platinum' THEN
        RETURN FALSE; -- Non-platinum users don't have voice access
    END IF;
    
    -- Check daily limit (30 minutes)
    SELECT COALESCE(SUM(quota_used), 0) INTO v_daily_used
    FROM plan_quotas
    WHERE user_id = p_user_id
      AND quota_type = 'voice_daily'
      AND period_start = CURRENT_DATE;
    
    IF v_daily_used + p_minutes > 30 THEN
        RETURN FALSE; -- Would exceed daily limit
    END IF;
    
    -- Check monthly limit (200 minutes)
    SELECT COALESCE(SUM(quota_used), 0) INTO v_monthly_used
    FROM plan_quotas
    WHERE user_id = p_user_id
      AND quota_type = 'voice_monthly'
      AND period_start = date_trunc('month', CURRENT_DATE);
    
    IF v_monthly_used + p_minutes > 200 THEN
        RETURN FALSE; -- Would exceed monthly limit
    END IF;
    
    RETURN TRUE;
END;
$$;

-- Function to update voice quota usage
CREATE OR REPLACE FUNCTION fn_update_voice_quota(
    p_user_id UUID,
    p_minutes INTEGER
) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    -- Update daily quota
    INSERT INTO plan_quotas (user_id, quota_type, quota_limit, quota_used, period_start, period_end)
    VALUES (p_user_id, 'voice_daily', 30, p_minutes, CURRENT_DATE, CURRENT_DATE)
    ON CONFLICT (user_id, quota_type, period_start)
    DO UPDATE SET 
        quota_used = plan_quotas.quota_used + EXCLUDED.quota_used,
        updated_at = NOW();
    
    -- Update monthly quota
    INSERT INTO plan_quotas (user_id, quota_type, quota_limit, quota_used, period_start, period_end)
    VALUES (
        p_user_id, 
        'voice_monthly', 
        200, 
        p_minutes, 
        date_trunc('month', CURRENT_DATE),
        date_trunc('month', CURRENT_DATE) + interval '1 month' - interval '1 day'
    )
    ON CONFLICT (user_id, quota_type, period_start)
    DO UPDATE SET 
        quota_used = plan_quotas.quota_used + EXCLUDED.quota_used,
        updated_at = NOW();
END;
$$;

-- Add comment to document the new plan features
COMMENT ON TYPE plan_type IS 'User subscription plans: free (3 questions/day), standard ($19/mo), pro ($49/mo), platinum ($89/mo with voice)';
COMMENT ON TYPE model_tier IS 'AI model tiers: basic (gpt-4o-mini), enhanced (gpt-4o), advanced (gpt-4o + features), realtime (voice + gpt-4o)';