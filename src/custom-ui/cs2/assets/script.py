import os
from PIL import Image
from PIL import ImageChops



if __name__ == "__main__":
    dir_path = 'weapons/models/'
    tgt_path = 'materials/'

    for weapon in os.listdir(dir_path):
        weapon_path = os.path.join(dir_path, weapon, 'materials/')

        color_img = None
        normal_img = None
        cavity_img = None
        rough_img = None
        masks_img = None
        orm_img = None

        for weapon_file in os.listdir(weapon_path):
            weapon_file_path = os.path.join(weapon_path, weapon_file)

            if os.path.isfile(weapon_file_path):
                with Image.open(weapon_file_path, mode='r') as img:
                    img = img.resize((2048, 2048)).convert('RGB')
                    if 'color' in weapon_file:
                        color_img = img
                    if 'normal' in weapon_file:
                        normal_img = img
                    if 'rough' in weapon_file:
                        rough_img = img
            
            elif weapon_file == 'composite_inputs':
                for ci_weapon_file in os.listdir(weapon_file_path):
                    ci_weapon_file_path = os.path.join(weapon_file_path, ci_weapon_file)

                    if os.path.isfile(weapon_file_path):
                        with Image.open(weapon_file_path, mode='r') as img:
                            img = img.resize((2048, 2048)).convert('RGB')
                            if 'cavity' in weapon_file:
                                cavity_img = img
                            if 'masks' in weapon_file:
                                masks_img = img

        cavity_r, cavity_g, _ = cavity_img.split()
        rough_r, rough_g, _ = rough_img.split()
        masks_r, _, _ = masks_img.split()

        orm_r = cavity_g
        orm_g = rough_r
        orm_b= ImageChops.add(masks_r, rough_g)

        orm_img = Image.merge("RGB", (orm_r, orm_g, orm_b))

        os.makedirs(os.path.join(tgt_path, weapon), exist_ok=True)
        
        color_img.save(os.path.join(tgt_path, weapon, 'color.jpg'))
        normal_img.save(os.path.join(tgt_path, weapon, 'normal.jpg'))
        orm_img.save(os.path.join(tgt_path, weapon, 'orm.jpg'))
        cavity_r.save(os.path.join(tgt_path, weapon, 'curvature.jpg'))
