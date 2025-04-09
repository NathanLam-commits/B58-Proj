#####################################################################
#
# CSCB58 Winter 2025 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Nathan Lam, 1008034949, lamnath8, nath.lam@mail.utoronto.ca
# # Bitmap Display
# Configuration:
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 512 
# - Display height in pixels: 512 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 4
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. double jump
# 2. start screen
# # Link to video demonstration for final submission:
# https://drive.google.com/file/d/1fqCTCc-gZfXh5db4GiX24xBRL5jrGgn6/view?usp=sharing
# # Are you OK with us sharing the video with people outside course staff? 
# - yes 
# https://github.com/NathanLam-commits/B58-Proj
# # Any additional information that the TA needs to know:
# Not sure if matters but I lowered 1 platform after the demo so the level is easier
#####################################################################

# addresses
.eqv BASE_ADDRESS 0x10008000
.eqv KEYBOARD_ADDRESS 0xFFFF0000

# constants
.eqv PIXEL_SIZE 4
.eqv ROW_SIZE 256 
.eqv SCREEN_WIDTH 64
.eqv BLACK 0x000000
.eqv GREY 0x555555
.eqv WHITE 0xFFFFFF
.eqv GREEN 0x00FF00
.eqv YELLOW 0xFFFF00
.eqv RED 0xFF0000


# keys
.eqv ASCII_W 0x77 
.eqv ASCII_A 0x61
.eqv ASCII_S 0x73
.eqv ASCII_D 0x64
.eqv ASCII_R 0x72
.eqv ASCII_Q 0x71
.eqv ASCII_Enter 0x0A
.eqv PIXEL_MAX 4096

.data
.align 2

# vars
pos_x: .word 0  # Initial x position
pos_y: .word 63  # Initial y position
gravity_counter: .word 0
jumping: .word 0
jump_counter: .word 2
health: .word 64
option: .word 0 
coins_collected: .word 0

# platform draw vars 
platforms: .word 15, 58, 10
	   .word 20, 40, 7
	   .word 40, 50, 10
	   .word 30, 30, 7 
	   .word -1, 27, 10
	   .word 55, 25, 6
num_plats: .word 6

# coin draw vars
coins: 	.word 20, 60, 0
	.word 45, 48, 0 
	.word 33, 28, 0
	.word 2, 30, 0
	.word 62, 11, 0
num_coins: .word 5

# spikes draw vars
spikes: .word 10, 63
	.word 25, 63
	.word 25, 30
	.word 22, 30
	.word 19,30
	.word 16, 30
	.word 13, 30
	.word 10, 30
	.word 28, 30
	.word 55, 15
	.word 59, 15
	.word 52, 15
	.word 62, 15
	
num_spikes: .word 13

# win screen draw vars
game_win: .word 527, 528, 529, 530, 531, 532, 533, 534, 538, 539, 540, 541, 542, 543, 544, 545, 549, 550, 551, 552, 553, 554, 
		555, 556, 590, 591, 593, 594, 595, 596, 598, 599, 601, 602, 603, 608, 609, 610, 612, 613, 615, 616, 617, 618, 
		620, 621, 654, 655, 657, 658, 659, 660, 662, 663, 665, 666, 668, 669, 670, 671, 673, 674, 676, 677, 679, 680, 
		681, 682, 684, 685, 718, 719, 721, 722, 723, 724, 726, 727, 729, 730, 732, 733, 734, 735, 737, 738, 740, 741, 
		743, 744, 745, 746, 748, 749, 782, 783, 785, 786, 787, 788, 790, 791, 793, 794, 796, 797, 798, 799, 801, 802, 
		804, 805, 807, 808, 809, 810, 812, 813, 846, 847, 848, 853, 854, 855, 857, 858, 860, 861, 862, 863, 865, 866, 
		868, 869, 871, 872, 873, 874, 876, 877, 910, 911, 912, 913, 914, 916, 917, 918, 919, 921, 922, 924, 925, 926, 
		927, 929, 930, 932, 933, 935, 936, 937, 938, 940, 941, 974, 975, 976, 977, 978, 980, 981, 982, 983, 985, 986, 
		988, 989, 990, 991, 993, 994, 996, 997, 999, 1000, 1001, 1002, 1004, 1005, 1038, 1039, 1040, 1041, 1042, 1044, 
		1045, 1046, 1047, 1049, 1050, 1052, 1053, 1054, 1055, 1057, 1058, 1060, 1061, 1063, 1064, 1065, 1066, 1068, 1069, 
		1102, 1103, 1104, 1105, 1106, 1108, 1109, 1110, 1111, 1113, 1114, 1116, 1117, 1118, 1119, 1121, 1122, 1124, 1125, 
		1127, 1128, 1129, 1130, 1132, 1133, 1166, 1167, 1168, 1169, 1170, 1172, 1173, 1174, 1175, 1177, 1178, 1179, 1184, 
		1185, 1186, 1188, 1189, 1190, 1195, 1196, 1197, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1242, 1243, 1244, 
		1245, 1246, 1247, 1248, 1249, 1253, 1254, 1255, 1256, 1257, 1258, 1259, 1260, 1359, 1360, 1361, 1362, 1363, 1364, 
		1365, 1366, 1370, 1371, 1372, 1373, 1374, 1375, 1376, 1377, 1381, 1382, 1383, 1384, 1385, 1386, 1387, 1388, 1422, 
		1423, 1425, 1426, 1427, 1428, 1430, 1431, 1433, 1434, 1435, 1439, 1440, 1441, 1442, 1444, 1445, 1447, 1448, 1449, 
		1450, 1452, 1453, 1486, 1487, 1489, 1490, 1491, 1492, 1494, 1495, 1497, 1498, 1499, 1500, 1502, 1503, 1504, 1505, 
		1506, 1508, 1509, 1511, 1512, 1513, 1514, 1516, 1517, 1550, 1551, 1553, 1554, 1555, 1556, 1558, 1559, 1561, 1562, 
		1563, 1564, 1566, 1567, 1568, 1569, 1570, 1572, 1573, 1576, 1577, 1578, 1580, 1581, 1614, 1615, 1617, 1618, 1619, 
		1620, 1622, 1623, 1625, 1626, 1627, 1628, 1630, 1631, 1632, 1633, 1634, 1636, 1637, 1640, 1641, 1642, 1644, 1645, 
		1678, 1679, 1681, 1684, 1686, 1687, 1689, 1690, 1691, 1692, 1694, 1695, 1696, 1697, 1698, 1700, 1701, 1703, 1705, 
		1706, 1708, 1709, 1742, 1743, 1745, 1748, 1750, 1751, 1753, 1754, 1755, 1756, 1758, 1759, 1760, 1761, 1762, 1764, 
		1765, 1767, 1769, 1770, 1772, 1773, 1806, 1807, 1809, 1812, 1814, 1815, 1817, 1818, 1819, 1820, 1822, 1823, 1824, 
		1825, 1826, 1828, 1829, 1831, 1832, 1834, 1836, 1837, 1870, 1871, 1874, 1875, 1878, 1879, 1881, 1882, 1883, 1884, 
		1886, 1887, 1888, 1889, 1890, 1892, 1893, 1895, 1896, 1898, 1900, 1901, 1934, 1935, 1938, 1939, 1942, 1943, 1945, 
		1946, 1947, 1948, 1950, 1951, 1952, 1953, 1954, 1956, 1957, 1959, 1960, 1961, 1964, 1965, 1998, 1999, 2001, 2002, 
		2003, 2004, 2006, 2007, 2009, 2010, 2011, 2015, 2016, 2017, 2018, 2020, 2021, 2023, 2024, 2025, 2028, 2029, 2063, 
		2064, 2065, 2066, 2067, 2068, 2069, 2070, 2074, 2075, 2076, 2077, 2078, 2079, 2080, 2081, 2085, 2086, 2087, 2088, 
		2089, 2090, 2091, 2092, 2701, 2702, 2713, 2717, 2719, 2720, 2721, 2722, 2724, 2727, 2729, 2732, 2764, 2767, 2777, 
		2778, 2780, 2781, 2783, 2788, 2789, 2791, 2793, 2796, 2828, 2831, 2835, 2836, 2837, 2841, 2843, 2845, 2847, 2848, 
		2849, 2852, 2854, 2855, 2857, 2860, 2892, 2894, 2905, 2909, 2911, 2916, 2919, 2921, 2924, 2957, 2959, 2969, 2973, 
		2975, 2976, 2977, 2978, 2980, 2983, 2986, 2987, 3084, 3085, 3086, 3097, 3098, 3099, 3102, 3103, 3104, 3105, 3108, 
		3109, 3110, 3112, 3113, 3114, 3115, 3117, 3118, 3119, 3120, 3121, 3148, 3151, 3161, 3164, 3166, 3171, 3176, 3183,
		3212, 3213, 3214, 3219, 3220, 3221, 3225, 3226, 3227, 3230, 3231, 3232, 3236, 3237, 3240, 3241, 3242, 3247, 3276, 
		3278, 3289, 3291, 3294, 3302, 3304, 3311, 3340, 3343, 3353, 3356, 3358, 3359, 3360, 3361, 3363, 3364, 3365, 3368, 
		3369, 3370, 3371, 3375

num_win: .word 694

# game over screen draw vars
game_over:  .word 910, 911, 912, 913, 916, 917, 918, 921, 925, 927, 928, 929, 930, 931, 973, 979, 983, 985, 986, 988, 989, 991, 
		1037, 1040, 1041, 1043, 1044, 1045, 1046, 1047, 1049, 1051, 1053, 1055, 1056, 1057, 1101, 1105, 1107, 1111, 
		1113, 1117, 1119, 1165, 1169, 1171, 1175, 1177, 1181, 1183, 1229, 1233, 1235, 1239, 1241, 1245, 1247, 1294, 1295, 
		1296, 1299, 1303, 1305, 1309, 1311, 1312, 1313, 1314, 1315, 1434, 1435, 1436, 1439, 1443, 1445, 1446, 1447, 1448, 
		1449, 1451, 1452, 1453, 1454, 1497, 1501, 1503, 1507, 1509, 1515, 1519, 1561, 1565, 1567, 1571, 1573, 1574, 1575, 
		1579, 1580, 1581, 1582, 1625, 1629, 1631, 1635, 1637, 1643, 1647, 1689, 1693, 1696, 1698, 1701, 1707, 1711, 1753, 
		1757, 1760, 1762, 1765, 1771, 1775, 1818, 1819, 1820, 1825, 1829, 1830, 1831, 1832, 1833, 1835, 1839, 2703, 2704, 
		2715, 2719, 2721, 2722, 2723, 2724, 2726, 2729, 2731, 2734, 2766, 2769, 2779, 2780, 2782, 2783, 2785, 2790, 2791, 
		2793, 2795, 2798, 2830, 2833, 2837, 2838, 2839, 2843, 2845, 2847, 2849, 2850, 2851, 2854, 2856, 2857, 2859, 2862, 
		2894, 2896, 2907, 2911, 2913, 2918, 2921, 2923, 2926, 2959, 2961, 2971, 2975, 2977, 2978, 2979, 2980, 2982, 2985, 
		2988, 2989, 3086, 3087, 3088, 3099, 3100, 3101, 3104, 3105, 3106, 3107, 3110, 3111, 3112, 3114, 3115, 3116, 3117, 
		3119, 3120, 3121, 3122, 3123, 3150, 3153, 3163, 3166, 3168, 3173, 3178, 3185, 3214, 3215, 3216, 3221, 3222, 3223, 
		3227, 3228, 3229, 3232, 3233, 3234, 3238, 3239, 3242, 3243, 3244, 3249, 3278, 3280, 3291, 3293, 3296, 3304, 3306, 
		3313, 3342, 3345, 3355, 3358, 3360, 3361, 3362, 3363, 3365, 3366, 3367, 3370, 3371, 3372, 3373, 3377

num_over: .word 266

# start screen draw vars
start: .word 1623, 1624, 1625, 1627, 1628, 1629, 1630, 1631, 1634, 1635, 1638, 1639, 1640, 1643, 1644, 1645, 1646,
	 1647, 1686, 1693, 1697, 1700, 1702, 1705, 1709, 1751, 1752, 1757, 1761, 1762, 1763, 1764, 1766, 1767, 1768, 
	 1773, 1817, 1821, 1825, 1828, 1830, 1832, 1837, 1878, 1879, 1880, 1885, 1889, 1892, 1894, 1897, 1901, 2455, 
	 2456, 2459, 2462, 2464, 2465, 2466, 2468, 2469, 2470, 2471, 2472, 2518, 2521, 2523, 2526, 2529, 2534, 2582, 
	 2585, 2587, 2590, 2593, 2598, 2646, 2648, 2651, 2654, 2657, 2662, 2711, 2713, 2716, 2717, 2720, 2721, 2722, 2726

num_start: .word 90

start_arrow: .word 1612, 1613, 1614, 1677, 1678, 1679, 1742, 1743, 1744, 1805, 1806, 1807, 1868, 1869, 1870
quit_arrow:  .word 2444, 2445, 2446, 2509, 2510, 2511, 2574, 2575, 2576, 2637, 2638, 2639, 2700, 2701, 2702

num_arrow: .word 15

#dont overwrite
# t0 = display address
# t1 = gravity counter
# s2 = pos x
# s3 = pos y
.text
main:
    	li $t0, BASE_ADDRESS  # Load base address of display
	
    	# Load initial position
    	la $s0, pos_x
    	la $s1, pos_y
    	li $s3, 63
    	sw $zero, 0($s0)
    	sw $s3, 0($s1)
    	lw $s2, 0($s0)  # Load x
    	lw $s3, 0($s1)  # Load y
	li $t9, 0
	
	# clear screen
	jal set_all_black
	# show start screen	
    	jal cstart
    	# player to start
	# reset all values
	jal reset
	
	# draw level
    	jal draw_dot  # Draw initial dot
    	li $t9, 0
    	la $t1, platforms       # Load the address of the platforms array
    	jal draw_platforms
    	
    	li $t9, 0
    	la $t1, coins       # Load the address of the platforms array
    	jal draw_coins
    	
    	li $t9, 0
    	la $t1, spikes       # Load the address of the platforms array
    	jal draw_spikes
	
	# begin checking input
    	j keyboard_loop

# gameplay loop: check for keypresses
keyboard_loop:
	# apply gravity (also applies jumping)
	jal apply_gravity
    	li $t9, KEYBOARD_ADDRESS
    	lw $t8, 0($t9) # read keyboard status
    	beq $t8, 1, keypress_happened # if a key is pressed, handle it
    	
    	j keyboard_loop  # loop

# jump to keyboard loop
return_to_loop:
	lw $ra, 0($sp)     # return address
    	addi $sp, $sp, 4
    	j keyboard_loop

# handle keypress
keypress_happened:
    	# read key pressed  	
    	lw $t8, 4($t9)
    	# handle key pressed  
    	beq $t8, ASCII_W, jump
    	beq $t8, ASCII_A, move_left
    	#beq $t8, ASCII_S, move_down
    	beq $t8, ASCII_D, move_right
    	beq $t8, ASCII_R, reset
    	beq $t8, ASCII_Q, main_menu

    	jr $ra 

# player jumps
jump:
	# check if can jump
	la $t2, jumping         
    	lw $t1, 0($t2)           
    	bge $t1, 1, return_from
    	
    	# jump
	la $t6, jump_counter
	lw $t5, 0($t6)
	ble $t5, 0, return_from
	subi $t5, $t5, 1
	sw $t5, 0($t6)
	
    	addi $t1, $t1, 10
	sw $t1, 0($t2)
    	jr $ra

# applies y-movement
apply_gravity:
	# increment counter and check if it is time to apply gravity yet    	
	la $t2, gravity_counter  
    	lw $t1, 0($t2)           
    	addi $t1, $t1, 1         
    	sw $t1, 0($t2)              	    	    	    	    	
    	blt $t1, 10000, return_from
    	# apply gravity (reset counter)
    	li $t1, 0
    	sw $t1, 0($t2)

	# check if we are jumping (move up if so, else move down)
	la $t2, jumping        
    	lw $t1, 0($t2)          
    	bge $t1, 1, move_up
    	
    	# move down
    	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	jal move_down
    	lw $ra, 0($sp)    
    	addi $sp, $sp, 4  
    	
    	jr $ra

# reduce player health
apply_damage:   
	# get health value and reduce 	
    	la $t6, health          
    	lw $t5, 0($t6)           
    	subi $t5, $t5, 16
    	sw $t5, 0($t6)
    	
    	# game over
    	ble $t5, 0, cgameover

	# show health
    	addi $sp, $sp, -4  # Allocate stack space
    	sw $ra, 0($sp)     # Save return addres
    	li $t9, 0
    	jal clear_health
    	li $t9, 0
    	jal print_health
    	lw $ra, 0($sp)     # Restore return address
    	addi $sp, $sp, 4   # Deallocate stack space   
    	
    	jr $ra

# clear health before showing
clear_health:
	# health var
    	la $t6, health          
    	lw $t5, 0($t6)
    	# return if we already cleared 64 pixels           
    	bge $t9, 64, return_from
    	li $t0, BASE_ADDRESS  
    	# compute address of new position
    	mul $t6, $t9, PIXEL_SIZE 
    	add $t7, $t0, $t6    
    	# draw (clear)    
  	li $t4, GREY
    	sw $t4, 0($t7)		
    	# increment
    	addi $t9, $t9, 1 	
    	# loop
    	j clear_health

# show health
print_health:
	# health var
    	la $t6, health         
    	lw $t5, 0($t6)          
    	# return if we already drew 64 pixels
    	bge $t9, $t5, return_from
    	li $t0, BASE_ADDRESS  
    	# compute address of new position
    	mul $t6, $t9, PIXEL_SIZE 
    	add $t7, $t0, $t6
    	# draw        
  	li $t4, RED
    	sw $t4, 0($t7)           
    	# increment
    	addi $t9, $t9, 1        
    	# loop
    	j print_health

# return to main menu
main_menu:
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   
    	j main

# clear player
clear_dot:
    	# compute address of current position
    	mul $t5, $s3, ROW_SIZE   # y * row size (row offset)
    	mul $t6, $s2, PIXEL_SIZE # x * pixel size (column offset)
    	add $t7, $t0, $t5        # add row offset
    	add $t7, $t7, $t6        # add column offset
    	# draw
    	li $t4, BLACK
    	sw $t4, 0($t7)         
    	sw $t4, -256($t7)
    	sw $t4, -512($t7)
    	
    	# redraw world to make sure we don't overwrite anything important
    	# platforms
	li $t9, 0
    	la $t1, platforms       
    	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	jal draw_platforms
    	#coins
    	li $t9, 0
    	la $t1, coins       
    	jal draw_coins
    	# spikes
    	li $t9, 0
    	la $t1, spikes       
    	jal draw_spikes
  	lw $ra, 0($sp)    
    	addi $sp, $sp, 4   
    	
    	jr $ra

# draw gameover loop
game_over_loop:
	# check if return
    	la $t6, num_over
    	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load vars
    	lw $t2, 0($t1)
    	li $t0, BASE_ADDRESS  
    	# Compute address to draw
    	mul $t6, $t2, PIXEL_SIZE 
    	add $t7, $t0, $t6      
    	# draw 
  	li $t4, WHITE
    	sw $t4, 0($t7)
    	# increment          
    	addi $t1, $t1, 4        
    	addi $t9, $t9, 1        
    	# loop
    	j game_over_loop

# draw winscreen loop
win_loop:
	# check if return
    	la $t6, num_win
    	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load vars
    	lw $t2, 0($t1)
    	li $t0, BASE_ADDRESS  
    	# Compute address to draw
    	mul $t6, $t2, PIXEL_SIZE 
    	add $t7, $t0, $t6        
    	# draw
  	li $t4, WHITE
    	sw $t4, 0($t7)   
    	# incrememnt      
    	addi $t1, $t1, 4       
    	addi $t9, $t9, 1      
    	# loop
    	j win_loop

# draw startscreen loop
start_screen_loop:
	# check if return
    	la $t6, num_start
    	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load vars
    	lw $t2, 0($t1)
    	li $t0, BASE_ADDRESS  
    	# Compute address to draw
    	mul $t6, $t2, PIXEL_SIZE
    	add $t7, $t0, $t6
    	# draw        
  	li $t4, WHITE
    	sw $t4, 0($t7)           
    	# incremement
    	addi $t1, $t1, 4        
    	addi $t9, $t9, 1       
    	# loop
    	j start_screen_loop

# call start screen
cstart:
	# set up vars and function params
    	li $t9, 0
    	la $t1, start       
    	addi $sp, $sp, -4 
    	sw $ra, 0($sp)
    	# clear screen     
	jal set_all_black
	# draw start screen
	li $t9, 0
    	jal start_screen_loop
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   
    	# draw arrow
    	j carrow

# check keypress on startscreen
start_loop:
    	li $t9, KEYBOARD_ADDRESS
    	lw $t8, 0($t9) 
    	beq $t8, 1, start_happened # key press happened, handle
    	
    	j start_loop 

# handle keypress on start screen
start_happened:
    	lw $t8, 4($t9)   # ASCII value of key pressed
    	# handle
    	beq $t8, ASCII_W, arrow_up
    	beq $t8, ASCII_S, arrow_down
    	beq $t8, ASCII_Enter, enter
    	beq $t8, ASCII_D, enter

    	j start_loop 

# move arrow up on start screen
arrow_up:
	# set position
	la $t9, option
	li $t8, 0
	sw $t8, 0($t9)
	# call draw arrow
	j carrow

# move arrow down on start screen
arrow_down:
	# set position
	la $t9, option
	li $t8, 1
	sw $t8, 0($t9)
	# call draw arrow
	j carrow

# call draw arrow
carrow:
	# set up function params
	li $t9, 0
    	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	# choose option for arrow to show
    	jal choose_option
    	# draw arrow on start screen
	li $t9, 0
    	la $t1, start_arrow       
    	jal arrow_loop
    	move $v0, $v1
    	li $t9, 0
    	la $t1, quit_arrow       
    	jal arrow_loop
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4  
    	# go back to checking input 
    	j start_loop

# draw arrow loop
arrow_loop:
	# check return
    	la $t6, num_arrow
    	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load vars
    	lw $t2, 0($t1)
    	li $t0, BASE_ADDRESS  
    	# compute draw position
    	mul $t6, $t2, PIXEL_SIZE 
    	add $t7, $t0, $t6     
    	# draw (colour is a param)
  	move $t4, $v0
    	sw $t4, 0($t7)          
    	# incremeent
    	addi $t1, $t1, 4      
    	addi $t9, $t9, 1   
    	# loops
    	j arrow_loop

# set colour params
set_start:
	li $v0, WHITE	
 	li $v1, BLACK
 	jr $ra
set_quit:
	li $v0, BLACK
 	li $v1, WHITE
 	jr $ra

# choose where arrow shows
choose_option:
	la $t9, option
	lw $t8, 0($t9)
	beq $t8, 0, set_start
	j set_quit

# user selects option
enter:
	# read option selected
	la $t9, option
	lw $t8, 0($t9)
	# start game
	beq $t8, 0, return_from
	# end program
	beq $t8, 1, quit
	j start_loop

# end program
quit:
	li $v0, 10
	syscall

# draw player
draw_dot:
    	li $t0, BASE_ADDRESS  
    	# Compute address of new position
    	mul $t5, $s3, ROW_SIZE   # y * row size (row offset)
    	mul $t6, $s2, PIXEL_SIZE # x * pixel size (column offset)
    	add $t7, $t0, $t5        # Add row offset
    	add $t7, $t7, $t6        # Add column offset

    	# draw
    	li $t4, WHITE
    	sw $t4, 0($t7)           # Write WHITE (0xFFFFFF)
    	sw $t4, -256($t7)
    	sw $t4, -512($t7)
    	
    	# check for coin collision
    	li $t9, 0
    	la $t1, coins      
    	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	jal check_near_coin
  	
  	# check for spike collision
    	li $t9, 0
    	la $t1, spikes      
    	jal check_on_spike
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4  

	jr $ra

# draw platforms
draw_platforms:
    	# check if return
    	la $t6, num_plats
    	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load platform position (x, y, length)
    	lw $t2, 0($t1)          # x
    	lw $t3, 4($t1)          # y
    	lw $t4, 8($t1)          # length
	# compute position to draw
	mul $t6, $t3, ROW_SIZE   
    	mul $t7, $t2, PIXEL_SIZE 
    	add $t8, $t0, $t6        
    	add $t8, $t8, $t7 
    	
    	# set params       
  	li $t5, GREEN
  	li $s5, 0
  	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	# draw full platform
  	jal platform_loop
  	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   

	# increment
    	addi $t9, $t9, 1              
    	addi $t1, $t1, 12
    	# loop
    	j draw_platforms

# draw platform given x,y,length
platform_loop:
	bge $s5, $t4, return_from
	addi $s5, $s5, 1
	addi $t8, $t8, 4
	sw $t5, 0($t8)           # Write WHITE (0xFFFFFF)
	j platform_loop

# general return to caller
return_from:
    jr $ra                  

# set colour to
set_black:
 	li $t5, BLACK
 	jr $ra
set_yellow:
 	li $t5, YELLOW
 	jr $ra

# choose colour to set coin
choose_colour:
	beq $t4, 1, set_black
	j set_yellow

# clear screen
set_all_black:
	# check return
    	bge $t9, PIXEL_MAX, return_from
    	li $t0, BASE_ADDRESS 
    	# compute pixel to clear 
    	mul $t6, $t9, PIXEL_SIZE 
    	add $t7, $t0, $t6       
    	# clear 
  	li $t4, BLACK
    	sw $t4, 0($t7)      
    	# increment     
    	addi $t9, $t9, 1        
	# loop
    	j set_all_black

# draw spikes
draw_spikes:
	# check return
	la $t6, num_spikes
   	lw $t5, 0($t6)
  	bge $t9, $t5, return_from
  	# load spike data (x,y)
   	lw $t2, 0($t1)          # x
   	lw $t3, 4($t1)          # y
   	# compute pixel to draw
   	mul $t6, $t3, ROW_SIZE   # y * row size (row offset)
   	mul $t7, $t2, PIXEL_SIZE # x * pixel size (column offset)
   	add $t8, $t0, $t6        # Add row offset
   	add $t8, $t8, $t7        # Add column offset
   	# draw
   	li $t5, RED
	sw $t5, 0($t8)           
	sw $t5, 4($t8)           
	sw $t5, -4($t8)          
	sw $t5, -256($t8)         
   	# incremement
   	addi $t9, $t9, 1              
   	addi $t1, $t1, 8
   	# loop
   	j draw_spikes

# draw coins
draw_coins:
	# check return
	la $t6, num_coins
   	lw $t5, 0($t6)
   	bge $t9, $t5, return_from
   	# load coin data (x, y, collected)
   	lw $t2, 0($t1)          # x
   	lw $t3, 4($t1)          # t
   	lw $t4, 8($t1)          # collected
   	# compute pixel to draw
   	mul $t6, $t3, ROW_SIZE   
   	mul $t7, $t2, PIXEL_SIZE 
   	add $t8, $t0, $t6      
   	add $t8, $t8, $t7        
   	# pick what colour to draw coin
   	# - not collected: Yellow
   	# - Collected:     Black
   	addi $sp, $sp, -4  
   	sw $ra, 0($sp)     
 	jal choose_colour
 	lw $ra, 0($sp)     
   	addi $sp, $sp, 4   
  	
  	# draw coin
	sw $t5, 0($t8)        
	sw $t5, 4($t8)          
	sw $t5, -4($t8)          
	sw $t5, 256($t8)          
	sw $t5, -256($t8)          
  	# increment
   	addi $t9, $t9, 1              
   	addi $t1, $t1, 12
   	#loop
   	j draw_coins

move_up:
	# move up
    	subi $t1, $t1, 1         
    	sw $t1, 0($t2)
    	# don't go off screen           
    	ble $s3, 3, return_to_loop
    	# clear player position and draw new
    	addi $sp, $sp, -4  
    	sw $ra, 0($sp)    
    	jal clear_dot
    	subi $s3, $s3, 1       
    	sw $s3, 0($s1)        
    	jal draw_dot
    	lw $ra, 0($sp)    
    	addi $sp, $sp, 4   
    	jr $ra

# move down
move_down:
	# don't go off screen
	bge $s3, 63, return_from_move_down # special return for jump counter
	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	# check platform collision
	li $t9, 0
    	la $t1, platforms       
    	li $s4, 0
    	addi $sp, $sp, -4  
    	sw $ra, 0($sp)    
    	jal check_on_plat
    	lw $ra, 0($sp)    
    	addi $sp, $sp, 4  
    	# on platform, don't move down
    	beq $s4, 1, return_from_move_down
    	
    	# clear player and draw in new position
	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	jal clear_dot
    	addi $s3, $s3, 1       
    	sw $s3, 0($s1)
    	jal draw_dot
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   
    	jr $ra
    	
# regain jump
return_from_move_down:
	la $t6, jump_counter
	li $t5, 2
	sw $t5, 0($t6)
	jr $ra

# set collission to true
set_true:
	li $s4, 1
	jr $ra

# check for coin collision
check_near_coin:
	# check return
    	la $t6, num_coins
    	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load coin data (x, y, collected)
    	lw $t2, 0($t1)         # x
    	lw $t3, 4($t1)         # y 
    	lw $t4, 8($t1)         # collected 
    	# increment
    	move $t7 $s3
    	subi $t7, $t7, 1	
	# check for collision
    	beq $t4, 0, check_c_Ypos

# check next coin
coin: 
    addi $t9, $t9, 1               
    addi $t1, $t1, 12
    j check_near_coin

# check y position
check_c_Ypos:
	move $t7 $t3
    	addi $t7, $t7, 1
	ble $s3, $t7, check_c_Yneg
	j coin
check_c_Yneg:
	move $t7 $t3
    	subi $t7, $t7, 1
	bge $s3, $t7, check_c2_Xneg
	j coin

# check x position
check_c2_Xneg:
	move $t7 $t2
    	subi $t7, $t7, 1
	bge $s2, $t7, check_c2_Xpos
	j coin
check_c2_Xpos: 
	move $t7 $t2
    	addi $t7, $t7, 1
	ble $s2, $t7, set_collected
	j coin
	
# set coin to collected
set_collected:
	# set coint o collected
	li $t4, 1
	sw $t4, 8($t1)
	# increment total coin collected
	la $t2, coins_collected
	lw $t3, 0($t2)
	addi $t3, $t3, 1
	sw $t3, 0($t2)
	# check win
	bge $t3, $t5, cwin
	jr $ra

# check spike collision
check_on_spike:
	# check return
    	la $t6, num_spikes
    	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load spike data (x, y)
    	lw $t2, 0($t1)          # x
    	lw $t3, 4($t1)          # y
    	# check collision
   	j check_s_Ypos

# check next spike
spike: 
    addi $t9, $t9, 1               
    addi $t1, $t1, 8
    j check_on_spike

# check spike Y position
check_s_Ypos:
	beq $s3, $t3, check_s_Xneg
	j spike

# check spike x position
check_s_Xneg:
	move $t7 $t2
    	subi $t7, $t7, 1
	bge $s2, $t7, check_s_Xpos
	j spike
check_s_Xpos: 
	move $t7 $t2
    	addi $t7, $t7, 1
	ble $s2, $t7, apply_damage
	j spike

# call gameover
cgameover:
	# sat parameters
    	li $t9, 0
    	la $t1, game_over       
    	addi $sp, $sp, -4 
    	sw $ra, 0($sp)     
    	# clear screen
	jal set_all_black
	li $t9, 0
	# print game over screen
    	jal game_over_loop
    	li $t9, 0
    	# show health
    	jal clear_health
    	li $t9, 0
    	jal print_health
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   
    	j over_loop

# check input during gameover
over_loop:
    	li $t9, KEYBOARD_ADDRESS
    	lw $t8, 0($t9) 
    	beq $t8, 1, reset_happened # key pressed
    	j over_loop  
    	
# call win
cwin:
	# sat parameters
    	li $t9, 0
    	la $t1, game_win       
    	addi $sp, $sp, -4 
    	sw $ra, 0($sp)  
    	# clear screen   
	jal set_all_black
	li $t9, 0
	# draw win screen
    	jal win_loop
    	li $t9, 0
    	# show health
    	jal clear_health
    	li $t9, 0
    	jal print_health
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   
    	j over_loop

# handle key press for win and gameover screen
reset_happened:
    	lw $t8, 4($t9)   # read ASCII value of key pressed
    	# handle
    	beq $t8, ASCII_R, reset
    	beq $t8, ASCII_Q, main_menu
    	j over_loop  

# reset game
reset:
	addi $sp, $sp, -4  
    	sw $ra, 0($sp)    
    	# clear screen
	li $t9, 0
	jal set_all_black
    	lw $ra, 0($sp)     
    	addi $sp, $sp, 4 
    	
    	# reset player position  
	li $s2, 0
	li $s3, 62  # set to 62 so gravity is applied, causing screen to update
	# reset player health
    	la $t2, health  
    	li $t1, 64
    	sw $t1, 0($t2)
    	# reset coins collected
    	la $t2, coins_collected
    	sw $zero, 0($t2)

	li $t9, 0
    	la $t1, coins       
    	addi $sp, $sp, -4  
    	sw $ra, 0($sp)    
    	# print health 
	li $t9, 0
	jal print_health
	# reset coin data to none collected
	li $t9, 0
    	jal reset_coins
  	lw $ra, 0($sp)    
    	addi $sp, $sp, 4   
    	# reset jumping
    	la $t2, jumping  
    	sw $zero, 0($t2) 
    	   
	jr $ra

# reset all coins to default
reset_coins:
	# check return
	la $t6, num_coins
   	lw $t5, 0($t6)
   	bge $t9, $t5, return_from
   	# set to not collected
   	sw $zero, 8($t1)          
   	# increment
   	addi $t9, $t9, 1               
   	addi $t1, $t1, 12
   	# loop
   	j reset_coins

# check platform collision
check_on_plat:
	# check return
    	la $t6, num_plats
   	lw $t5, 0($t6)
    	bge $t9, $t5, return_from
    	# load platform data (x, y, length)
    	lw $t2, 0($t1)          # x
    	lw $t3, 4($t1)          # y
    	lw $t4, 8($t1)          # length
    	# increment
    	move $t7 $s3
    	addi $t7, $t7, 1
    	# check platform collision
    	beq $t7, $t3, check

# check next platform
plat2: 
    	addi $t9, $t9, 1              
    	addi $t1, $t1, 12
    	j check_on_plat

# check platform colision
check:
	bgt $s2, $t2, check2
	j plat2
check2: 
	add $s5, $t2, $t4
	ble $s2, $s5, set_true
	j plat2

# move left
move_left:
	# don't go off screen
    	ble $s2, 0, return_to_loop
    	# clear current position
       	addi $sp, $sp, -4  
    	sw $ra, 0($sp)     
    	jal clear_dot
    	# change player position
    	subi $s2, $s2, 1       
    	sw $s2, 0($s0)
    	# draw new position
    	jal draw_dot
       	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   
    	jr $ra

move_right:
	# don't go off screen
	bge $s2, 63, return_to_loop
	# clear current position
    	addi $sp, $sp, -4 
    	sw $ra, 0($sp)    
    	jal clear_dot
    	# change player position
    	addi $s2, $s2, 1       
    	sw $s2, 0($s0)
    	# draw new position
    	jal draw_dot
       	lw $ra, 0($sp)     
    	addi $sp, $sp, 4   
    	jr $ra
