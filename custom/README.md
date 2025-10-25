# 自定义工具箱

## 简介

这是基于 [kejilion/sh](https://github.com/kejilion/sh) 上游项目的自定义工具箱扩展。

## 目录结构

```
custom/
├── custom_main.sh       # 主入口脚本
├── tools/               # 工具脚本目录
│   ├── tool1.sh        # 示例工具 1
│   ├── tool2.sh        # 示例工具 2
│   └── tool3.sh        # 示例工具 3
├── config/              # 配置文件目录
│   └── settings.conf   # 主配置文件
└── README.md           # 本文档
```

## 使用方法

### 启动自定义工具箱

在 Linux 系统上：

```bash
bash custom/custom_main.sh
```

或者赋予执行权限后直接运行：

```bash
chmod +x custom/custom_main.sh
./custom/custom_main.sh
```

### 添加新工具

1. 在 `custom/tools/` 目录下创建新的 `.sh` 脚本
2. 编写工具功能代码
3. 在 `custom_main.sh` 的菜单中添加对应的选项
4. 赋予脚本执行权限：`chmod +x custom/tools/your_tool.sh`

### 示例：创建新工具

```bash
# 1. 创建新工具脚本
cat > custom/tools/my_tool.sh << 'EOF'
#!/bin/bash
echo "这是我的自定义工具"
# 添加你的功能代码
read -p "按回车键返回..."
EOF

# 2. 赋予执行权限
chmod +x custom/tools/my_tool.sh

# 3. 在 custom_main.sh 中添加菜单项（手动编辑）
```

## 配置说明

配置文件位于 `custom/config/settings.conf`，可以在此文件中设置：

- 工具箱版本信息
- 自定义配置项
- 环境变量
- 日志配置

## 开发规范

1. **脚本命名**：使用小写字母和下划线，如 `my_tool.sh`
2. **注释规范**：每个脚本开头添加功能说明注释
3. **错误处理**：添加适当的错误检查和提示
4. **用户交互**：使用清晰的提示信息
5. **代码风格**：保持与上游项目一致的代码风格

## 注意事项

- ⚠️ 不要修改上游 `kejilion.sh` 文件
- ⚠️ 所有自定义功能放在 `custom/` 目录下
- ⚠️ 定期同步上游更新
- ⚠️ 敏感配置使用环境变量或独立配置文件
- ⚠️ 测试新功能后再部署到生产环境

## 版本历史

- **v1.0.0** (2025-01-25)
  - 初始版本
  - 创建基础目录结构
  - 添加示例工具脚本

## 技术支持

- 上游项目：https://github.com/kejilion/sh
- 问题反馈：请在项目 Issues 中提出

## 许可证

遵循上游项目的许可证
