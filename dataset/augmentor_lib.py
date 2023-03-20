import Augmentor

p = Augmentor.Pipeline('./data/9')

p.rotate(probability=1, max_left_rotation=15, max_right_rotation=15)
p.random_distortion(probability=1, grid_width=4, grid_height=4, magnitude=3)
p.gaussian_distortion(1, 5, 5, 1, 'bell', 'in')
p.random_brightness(1, .2, 1.5)

p.sample(250)
