# 安心健康助理 · Flutter Material 3 Starter

这是一套**可联动、可跑**的 Flutter M3 界面骨架：
- 底部 5 Tab：助理 / 任务 / 记录 / 家人 / 我的
- **额度逻辑**：免费用户每日 3 问（本地模拟，支持跨天重置）；付费用户无限*
- **模型徽章**：基础 / 增强 / 高级（仅展示，不改变页面）
- 对话支持“动作卡片”：设为任务 / 导出摘要 / 分享给家属（示例操作）
- 适老化：全局字体缩放、M3 组件、舒适的留白与对比度

> 注意：本项目演示 UI 交互与本地状态，不含真实后端与 IAP。你可以把本骨架接上你们的 API。

## 快速开始

```bash
# 解压后进入目录
flutter create .         # 生成 android/ios/web 等平台目录（如已存在可略过）
flutter pub get
flutter run
```

## 目录结构
```
lib/
  app.dart               # App Shell, NavigationBar + IndexedStack
  main.dart
  models/models.dart     # Plan/ModelTier/Message/Task/Member
  state/app_state.dart   # 全局状态（配额、模型、消息、任务）
  pages/
    assistant_page.dart  # 助理页（对话 + 配额/模型徽章 + 动作卡片 + 发送/麦克风）
    tasks_page.dart      # 任务列表
    task_edit_page.dart  # 任务编辑
    logs_page.dart       # 记录（平安打卡 + 指标卡片）
    circle_page.dart     # 照护圈（邀请与共享示例）
    settings_page.dart   # 订阅与模型、字体大小、隐私与关于
  widgets/
    quota_badge.dart     # 今日 3/3 / 无限*
    model_badge.dart     # 基础/增强/高级 徽章
    message_bubble.dart  # 气泡 + 动作 Chip
    paywall_sheet.dart   # 额度用尽底部弹层
```

## 你可以立即做的修改
- 将 `state/app_state.dart` 的 `ask()` 方法替换为**调用你的 .NET 后端**（OpenAI Realtime），并根据后端返回填充 `actions`。
- 将**扣额时机**从“发送”切换为“收到第一段回复”——只需在 UI 层改为在 `ask()` 返回后再扣或在后端扣。
- 把“导出摘要/分享给家属”接到你们的**文档/共享 API**。
- 用 `shared_preferences` 已持久化了 `usedToday/lastAskDay/plan/tier/textScale`，可按需扩展。

## 设计细节
- 主题：`ThemeData(useMaterial3: true, ColorScheme.fromSeed(Colors.teal))`
- 触控热区：控件 ≥48×48dp；文本行高 1.35；卡片留白 16dp
- 适老化：`MediaQuery.textScaleFactor` 全局可调（0.9–1.4）

## 许可
此样例供你在商业项目中自由使用与改造。
