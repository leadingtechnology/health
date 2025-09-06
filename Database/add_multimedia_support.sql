-- Add multimedia support tables for messages and attachments
-- Run this after the main health_postgres.sql

-- Messages table for conversation messages
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user', -- user, assistant, system
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_message_role CHECK (role IN ('user', 'assistant', 'system'))
);

-- Indexes for messages
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_user ON public.messages(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);

-- Message attachments table for images, audio, and other files
CREATE TABLE IF NOT EXISTS public.message_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    file_type VARCHAR(20) NOT NULL, -- image, audio, document
    storage_path TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    thumbnail_path TEXT,
    duration_seconds INT,
    transcription_text TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_attachment_file_type CHECK (file_type IN ('image', 'audio', 'document'))
);

-- Indexes for attachments
CREATE INDEX IF NOT EXISTS idx_attachments_message ON public.message_attachments(message_id);
CREATE INDEX IF NOT EXISTS idx_attachments_file_type ON public.message_attachments(file_type);

-- Grant permissions
GRANT ALL ON public.messages TO postgres;
GRANT ALL ON public.message_attachments TO postgres;

-- Add audit logging for messages
CREATE OR REPLACE FUNCTION audit_messages() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Message created: % for conversation %', NEW.id, NEW.conversation_id;
    ELSIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Message deleted: %', OLD.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_messages
AFTER INSERT OR DELETE ON public.messages
FOR EACH ROW EXECUTE FUNCTION audit_messages();

-- Function to get message count for a conversation
CREATE OR REPLACE FUNCTION get_conversation_message_count(p_conversation_id UUID)
RETURNS INT AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.messages WHERE conversation_id = p_conversation_id);
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to get attachment stats for a user
CREATE OR REPLACE FUNCTION get_user_attachment_stats(p_user_id UUID)
RETURNS TABLE(
    total_attachments BIGINT,
    total_size_bytes BIGINT,
    image_count BIGINT,
    audio_count BIGINT,
    document_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(a.id) as total_attachments,
        COALESCE(SUM(a.file_size), 0) as total_size_bytes,
        COUNT(a.id) FILTER (WHERE a.file_type = 'image') as image_count,
        COUNT(a.id) FILTER (WHERE a.file_type = 'audio') as audio_count,
        COUNT(a.id) FILTER (WHERE a.file_type = 'document') as document_count
    FROM public.message_attachments a
    INNER JOIN public.messages m ON a.message_id = m.id
    WHERE m.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Sample data for testing (optional - comment out in production)
/*
-- Insert a test message with attachment
DO $$
DECLARE
    v_user_id UUID;
    v_conv_id UUID;
    v_msg_id UUID;
BEGIN
    -- Get first user
    SELECT id INTO v_user_id FROM public.users LIMIT 1;
    
    -- Get or create a conversation
    SELECT id INTO v_conv_id FROM public.conversations WHERE owner_user_id = v_user_id LIMIT 1;
    
    IF v_conv_id IS NOT NULL THEN
        -- Create a message
        INSERT INTO public.messages (id, conversation_id, user_id, content, role)
        VALUES (gen_random_uuid(), v_conv_id, v_user_id, 'Test message with image attachment', 'user')
        RETURNING id INTO v_msg_id;
        
        -- Add an attachment
        INSERT INTO public.message_attachments (message_id, file_name, content_type, file_type, storage_path, file_size)
        VALUES (v_msg_id, 'test_image.jpg', 'image/jpeg', 'image', '/uploads/image/2024-01/test.jpg', 1024000);
        
        RAISE NOTICE 'Test message and attachment created';
    END IF;
END $$;
*/