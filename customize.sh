#!/system/bin/sh

MODDIR="$MODPATH"

SRC_FILE="/product/etc/fonts_customization.xml"
DEST_FILE="$MODDIR/system/product/etc/fonts_customization.xml"
SOURCE_XML="$MODDIR/Source.xml"

if [ -f "$DEST_FILE" ] && [ -f "$SOURCE_XML" ]; then
    ui_print " "
    ui_print "- 检测到模块已安装，使用已有 Source.xml 进行合并..."
else

    if [ ! -f "$SRC_FILE" ]; then
        ui_print " "
        ui_print "- 此系统环境不受支持。"
        exit 1
    fi

    mkdir -p "$MODDIR/system/product/etc"
    if cp -af "$SRC_FILE" "$DEST_FILE"; then
        ui_print " "
        ui_print "- 正在获取系统字体配置文件..."
    else
        ui_print " "
        ui_print "- 获取系统字体配置文件失败。"
        ui_print " "
        exit 1
    fi

    if ! cp -af "$SRC_FILE" "$SOURCE_XML"; then
        ui_print "- 获取系统字体配置文件失败。"
        exit 1
    fi

fi

FONT_CONFIG_TMP=$(mktemp)
if unzip -p "$ZIPFILE" "FontConfig.xml" > "$FONT_CONFIG_TMP"; then
    ui_print " "
    ui_print "- 正在读取 FontConfig.xml 字体配置文件..."
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

ui_print " "
ui_print "- 正在合并系统字体配置文件..."
sleep 4
sed '$d' "$SOURCE_XML" > "$TMPFILE"
cat "$FONT_CONFIG_TMP" >> "$TMPFILE"
echo "" >> "$TMPFILE"
sed -n '$p' "$SOURCE_XML" >> "$TMPFILE"
mv -f "$TMPFILE" "$DEST_FILE"
rm -f "$FONT_CONFIG_TMP"

ui_print " "
ui_print "- 合并完成。"
ui_print " "

set_perm_recursive "$MODDIR" 0 0 0755 0644

ui_print "- 安装完成。"
ui_print " "
