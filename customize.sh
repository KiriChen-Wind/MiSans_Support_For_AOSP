#!/system/bin/sh

MODDIR="$MODPATH"

SRC_FILE="/product/etc/fonts_customization.xml"
DEST_FILE="$MODDIR/system/product/etc/fonts_customization.xml"

if [ ! -f "$SRC_FILE" ]; then
    ui_print " "
    ui_print "- 此系统环境不受支持。"
    exit 1
fi

TMP_SRC=$(mktemp)
if [ ! -f "$TMP_SRC" ]; then
    ui_print " "
    ui_print "- 创建临时文件失败。"
    exit 1
fi

if grep -q "<!-- MiSans by KiriChen-->" "$SRC_FILE"; then
    # 旧配置清理
    awk '
    /<!-- MiSans by KiriChen-->/ { skip=30; next }
    skip>0 { skip--; next }
    1
    ' "$SRC_FILE" > "$TMP_SRC"
    ui_print " "
    ui_print "- 检测到旧配置，正在清理.. "
    sleep 3
else
    # 没有旧配置
    cp -af "$SRC_FILE" "$TMP_SRC"
fi

# 将处理后的系统文件复制到模块目录
mkdir -p "$MODDIR/system/product/etc"
if cp -af "$TMP_SRC" "$DEST_FILE"; then
    ui_print " "
    ui_print "- 获取到系统字体配置文件。"
    sleep 1
else
    ui_print " "
    ui_print "- 获取系统字体配置文件失败。"
    rm -f "$TMP_SRC"
    exit 1
fi
rm -f "$TMP_SRC"

FONT_CONFIG_TMP=$(mktemp)
if unzip -p "$ZIPFILE" "FontConfig.xml" > "$FONT_CONFIG_TMP"; then
    ui_print " "
    ui_print "- 正在读取 FontConfig.xml 字体配置文件..."
    sleep 2
else
    ui_print " "
    ui_print "- FontConfig.xml 字体配置文件读取失败。"
    ui_print "- 请检查此模块完整性。"
    rm -f "$FONT_CONFIG_TMP"
    exit 1
fi

TMPFILE=$(mktemp)
if [ ! -f "$TMPFILE" ]; then
    ui_print " "
    ui_print "- 创建临时文件失败。"
    rm -f "$FONT_CONFIG_TMP"
    exit 1
fi

# 配置合并
ui_print " "
ui_print "- 正在合并系统字体配置文件..."
sleep 4
sed '$d' "$DEST_FILE" > "$TMPFILE"
cat "$FONT_CONFIG_TMP" >> "$TMPFILE"
echo "" >> "$TMPFILE"
echo "" >> "$TMPFILE"
sed -n '$p' "$DEST_FILE" >> "$TMPFILE"
mv -f "$TMPFILE" "$DEST_FILE"
rm -f "$FONT_CONFIG_TMP"

ui_print " "
ui_print "- 合并完成。"
ui_print " "

set_perm_recursive "$MODDIR" 0 0 0755 0644

ui_print "- 安装完成。"
ui_print " "
