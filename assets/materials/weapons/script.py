from os.path import curdir as cd, abspath as fpath, exists, isdir
from os import listdir as ls, remove as rmf
from shutil import move as mv, rmtree as rmd
from PIL import Image

SIZE_2048 = (2048, 2048)


def collect_orm(ao, rough, masks, metal=None):
    r_c = ao.resize(SIZE_2048)
    g_c = rough.resize(SIZE_2048)
    b_c = masks.resize(SIZE_2048).getchannel(0)

    if metal:
        metal_mask = metal.resize(SIZE_2048)
        g_c = Image.composite(Image.new(mode='L',
                                        size=SIZE_2048,
                                        color=16), g_c, metal_mask)
        b_c = Image.composite(Image.new(mode='L',
                                        size=SIZE_2048,
                                        color=255), b_c, metal_mask)

    return Image.merge("RGB", (r_c, g_c, b_c))


for d in ls(cd):
    if isdir(d) and not d.endswith('idea'):
        d_mat = f'{fpath(d)}/materials'
        if exists(d_mat):
            for f in ls(d_mat):
                src = f'{fpath(d_mat)}/{f}'
                dst = f'{fpath(d)}/{f}'
                mv(src, dst)
                rmd(fpath(d_mat))

        d_color_img = None
        d_normal_img = None
        d_roughness_img = None
        d_metal_img = None
        d_masks_img = None
        d_ao_img = None

        for f in ls(fpath(d)):
            if f == 'composite_inputs':
                for f_i in ls(f'{fpath(d)}/{f}'):
                    if 'masks' in f_i:
                        d_masks_img = Image.open(f'{fpath(d)}/{f}/{f_i}')
            else:
                try:
                    if 'color' in f:
                        d_color_img = Image.open(f'{fpath(d)}/{f}')
                    elif 'normal' in f:
                        d_normal_img = Image.open(f'{fpath(d)}/{f}')
                    elif 'rough' in f:
                        d_roughness_img = Image.open(f'{fpath(d)}/{f}')
                    elif 'metal' in f:
                        d_metal_img = Image.open(f'{fpath(d)}/{f}')
                    elif 'ao' in f:
                        d_ao_img = Image.open(f'{fpath(d)}/{f}')
                except Exception:
                    pass

        if d_ao_img and d_roughness_img and d_masks_img and d_metal_img:
            orm_tex = collect_orm(d_ao_img,
                                  d_roughness_img,
                                  d_masks_img,
                                  d_metal_img)

            orm_tex.save('w_orm.jpg', quality=90)
            d_ao_img.close()
            d_roughness_img.close()
            d_masks_img.close()
            d_metal_img.close()

        if d_color_img:
            albedo_tex = d_color_img.resize(SIZE_2048).convert('RGB')
            albedo_tex.save('w_albedo.jpg', quality=90)
            d_color_img.close()

        if d_normal_img:
            d_normal_img.resize(SIZE_2048)
            d_normal_img.save('w_normal.jpg', quality=90)
            d_normal_img.close()

for d in ls(cd):
    if isdir(d) and not d.startswith('.'):
        for f in ls(fpath(d)):
            if f.endswith(("w_orm.jpg", "w_albedo.jpg", "w_normal.jpg")):
                continue
            else:
                try:
                    path = f'{fpath(d)}/{f}'
                    if isdir(path):
                        rmd(path)
                    else:
                        rmf(path)
                except Exception as e:
                    print(e)
