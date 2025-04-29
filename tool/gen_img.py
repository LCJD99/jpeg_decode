from PIL import Image, ImageDraw

# 创建32x32的RGB图像
image = Image.new('RGB', (32, 32))
draw = ImageDraw.Draw(image)

# 定义4种颜色（这里使用红、绿、蓝、黄）
colors = [
    (255, 0, 0),    # 红色
    (0, 255, 0),    # 绿色
    (0, 0, 255),    # 蓝色
    (255, 255, 0)   # 黄色
]

# 计算每个色块的大小（32/2=16，所以每个色块是16x16）
block_size = 16

# 绘制4个色块
draw.rectangle([(0, 0), (block_size, block_size)], fill=colors[0])      # 左上角红色
draw.rectangle([(block_size, 0), (32, block_size)], fill=colors[1])   # 右上角绿色
draw.rectangle([(0, block_size), (block_size, 32)], fill=colors[2])    # 左下角蓝色
draw.rectangle([(block_size, block_size), (32, 32)], fill=colors[3])  # 右下角黄色

# 保存为JPEG文件
image.save('color_blocks.jpg', 'JPEG')
