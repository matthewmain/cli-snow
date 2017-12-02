##################
##     SNOW     ##
##################


class Window

	def initialize
		puts "\n\nSnow's about to fall...\n\n"; sleep 1.5; 300.times {puts "\n"}
		#window settings
		@@width = get_positive_integer_from_answer_to("Terminal window width:\n\n"); clear_screen
		@@height = get_positive_integer_from_answer_to("Terminal window height:\n\n"); clear_screen
		@@window = (" " * @@width + "\n") * @@height
		@@frame_count = 0
		@@object_map = (" " * @@width + "\n") * @@height
		#flake settings
		@@snow_layers = get_boolean_from_yes_no_answer_to("Should the snow fall in layers? (\"yes\"/\"no\")\n\n"); clear_screen
		@@accumulate_at_base = get_option_from_answer_to("Should falling snow accumulate at the base or pass through it? \n\n1) \"accumulate\"\n2) \"pass through\"\n\n", "accumulate","pass through"); @@accumulate_at_base == "accumulate" ? @@accumulate_at_base = true : @@accumulate_at_base = false; clear_screen
		@@universe = get_option_from_answer_to("Should falling snow build up at the window's edges or pass through them? \n\n1) \"build up\"\n2) \"pass through\"\n\n", "build up","pass through"); @@universe == "build up" ? @@universe = "snow globe" : @@universe = "infinite"; clear_screen
		@@slippery_objects = true #!get_boolean_from_yes_no_answer_to("Should the snow accumulate on the slopes of objects like roofs or funnels? (\"yes\"/\"no\")\n\n"); clear_screen
		@@flake_count = 0
		set_layers
		set_intensity
		#breeze settings
		@@breeze_setting = get_option_from_answer_to("What kind of breeze?\n\n1) \"strong left\"\n2) \"moderate left\"\n3) \"light left\"\n4) \"light right\"\n5) \"moderate right\"\n6) \"strong right\"\n7) \"changing\"\n8) \"gusty\"\n9) \"none\"\n\n", "strong left", "moderate left", "light left", "light right", "moderate right", "strong right", "changing", "gusty", "none"); clear_screen
		set_breeze
		#structure settings
		@@structures = get_option_from_answer_to("What kind of structures?\n\n1) \"spires\"\n2) \"stairs\"\n3) \"tiers\"\n4) \"upward staggered ladder\"\n5) \"downward staggered ladder\"\n6) \"funnel\"\n7) \"bottle\"\n8) \"funnel and flask\"\n9) \"high platform\"\n10) \"low platform\"\n11) \"platform and slides\"\n12) \"randomized platforms\"\n13) \"leaking bucket\"\n14) \"chambers\"\n15) \"house\"\n16) \"randomize\"\n17) \"spotify album cover box (@5x zoom)\"\n18) \"lonely phone booth\"\n19) \"none\"\n\n", "spires", "stairs", "tiers", "upward staggered ladder", "downward staggered ladder", "funnel", "bottle", "funnel and flask", "high platform", "low platform", "platform and slides", "randomized platforms", "leaking bucket", "chambers", "house", "randomize", "spotify album cover box (@5x zoom)", "lonely phone booth", "none")
		build_structures
		select_randomized_structures if @@structures == "randomize" || @@structures == "randomized platforms"
		#initialize
		puts @@window.split("\n")[0..-2].join("\n"); puts "Ready? (hit \"enter\" to begin)\n"; gets

		# #quick startup for testing
		# @@width = 251
		# @@height = 77
		# @@window = (" " * @@width + "\n") * @@height
		# @@frame_count = 0
		# @@object_map = (" " * @@width + "\n") * @@height
		# @@snow_layers = true 
		# @@universe = "infinite"
		# @@accumulate_at_base = true
		# @@slippery_objects = true 
		# @@flake_count = 0
		# set_layers
		# set_intensity
		# @@breeze_setting = "changing"
		# set_breeze
		# @@structures = "lonely phone booth"
		# build_structures
		# select_randomized_structures if @@structures == "randomize" || @@structures == "randomized platforms"

	end


	### USER INTERACTION ###

	def get_positive_integer_from_answer_to(question)
		puts question
		answer = gets.chomp
		if answer.to_i > 0
			answer.to_i
		else
			clear_screen; puts "\nHmm... \"#{answer}\" isn't a valid answer. Should be a number greater than zero. Try again.\n\n"
			get_positive_integer_from_answer_to(question)
		end
	end

	def get_boolean_from_yes_no_answer_to(question)
		puts question
		answer = gets.chomp
		if answer.downcase == "n" || answer.downcase == "no"
			false
		elsif answer.downcase == "y" || answer.downcase == "yes"
			true
		else
			clear_screen; print "Hmm... Didn't quite understand \"#{answer}\". Enter \"yes\" or \"no\". Try again.\n\n"
			get_boolean_from_yes_no_answer_to(question)
		end
	end

	def get_option_from_answer_to(question, *options)
		puts question
		answer = gets.chomp.downcase
		if answer.to_i.between?(1,options.count) #lets answer be a number corresponding to the option's order
			options[answer.to_i-1]
		elsif options.all? { |option| option.downcase != answer}
			clear_screen; print "Hmm... \"#{answer}\" isn't an option. Try again.\n\n"
			get_option_from_answer_to(question,*options)
		else
			answer
		end
	end


	### SNOW EFFECTS ###

	def set_layers
		if @@snow_layers == true
			@@layer_flake_array_1 = (["."]*17) +(["●"]*2) +(["•"]*1)  	 # (note that these medium dots appear as
			@@layer_flake_array_2 = (["."]*1)  +(["●"]*2) +(["•"]*8)     # larger dots and vice versa in Terminal)
			@@layer_flake_array_now = [@@layer_flake_array_1,@@layer_flake_array_2].sample
			@@layer_flake_count = 0
			@@layer_size = rand(2..8)*@@width
		end
	end

	def set_intensity
		@@intensity_level = "heavy"
		@@intensity_duration = rand(60..300) #1-5 minutes
		@@intensity_expiration = Time.now + @@intensity_duration
	end

	def set_breeze
		# initializes breeze for 'changing' and 'gusty' settings
		if @@breeze_setting == "changing" || @@breeze_setting == "gusty"
			@@breeze_begin_time = Time.now
			@@breeze_now ||= "none"
			@@swing_direction ||= ["left","right"].sample
			# sets/updates 'changing' breeze
			if @@breeze_setting == "changing"
				@@breeze_array = ["strong left", "moderate left", "light left", "none", "light right", "moderate right", "strong right"]
				@@breeze_array = @@breeze_array.inject([]) do |new_arr,breeze|
					case breeze
						when /strong/ 	then new_arr += [breeze]*1 
						when /moderate/ then new_arr += [breeze]*2 
						when /light/		then new_arr += [breeze]*4
						when /none/			then new_arr += [breeze]*3 
					end
				end	
				@@breeze_now = @@breeze_array.sample
				@@breeze_duration_in_seconds = rand(30..300)
			# sets/udpates 'gusty' breeze
			elsif @@breeze_setting == "gusty"
				case @@breeze_now
					when "strong left"
						@@breeze_now = "moderate left"; @@swing_direction = "right"
					when "moderate left"
						case @@swing_direction
							when "left" then @@breeze_now = "strong left"; @@swing_direction = "right"
							when "right" then @@breeze_now = "none"; @@swing_direction = ["left","right","right"].sample
						end
					when "none"
						case @@swing_direction
							when "left" then @@breeze_now = "moderate left"; @@swing_direction = "left"
							when "right" then @@breeze_now = "moderate right"; @@swing_direction = "right"
						end
					when "moderate right"
						case @@swing_direction
							when "left" then @@breeze_now = "none"; @@swing_direction = @@swing_direction = ["left","left","right"].sample
							when "right" then @@breeze_now = "strong right"; @@swing_direction = "left"
						end
					when "strong right"
						@@breeze_now = "moderate right"; @@swing_direction = "left"
				end
				case @@breeze_now
					when /strong/ 	then @@breeze_duration_in_seconds = ([3] +[4] +([5]*2) +([6]*2) +[7]).sample
					when /moderate/ then @@breeze_duration_in_seconds = [0.5,0.75,1].sample
					when /none/			then @@breeze_duration_in_seconds = [0.5,0.75,1,2].sample
				end
			end
		# initializes breeze for all other settings	
		else
			@@breeze_now = @@breeze_setting
		end
	end

	def update_intensity 
		Snowflake.new_intensity if Time.now > @@intensity_expiration 
	end

	def update_breeze
		if @@breeze_setting == "changing" || @@breeze_setting == "gusty"
			set_breeze if (Time.now - @@breeze_begin_time) > @@breeze_duration_in_seconds
		end
	end



	### COORDINATES ###

	def get_coord(right,down)
		(@@width+1) * (down-1) + (right-1)
	end
	

	### STRUCTURES ###

	def add_object(right,down,character)
		coord = get_coord(right,down)
		@@object_map[coord] = "O"
		update_window_coord(right,down,character)
	end

	def remove_object(right,down)
		coord = get_coord(right,down)
		@@object_map[coord] = " "
		@@window[coord] = " "
	end

	def place_horizontal_line(right_begin_pct,down_pct,right_end_pct,dimension_lock=false)
		width = @@width; height = @@height
		right_begin = (@@width*right_begin_pct).round; right_begin = 1 if right_begin == 0
		down = (@@height*down_pct).round; down = 1 if down == 0
		right_end = (@@width*right_end_pct).round
		if dimension_lock
			if @@width > @@height
				width = @@height
				right_begin = (width*right_begin_pct).round + ((@@width-@@height)/2).round
				right_end = (width*right_end_pct).round + ((@@width-@@height)/2).round
			elsif @@height > @@width
				height = @@width
				down = (height*down_pct).round + ((@@height-@@width)/2).round
			end
		end			
		(right_begin..right_end).each {|right| add_object(right,down,"═")}
	end

	def place_vertical_line(right_pct,down_begin_pct,down_end_pct,dimension_lock=false)
		width = @@width; height = @@height
		right = (@@width*right_pct).round; right = 1 if right == 0
		down_begin = (@@height*down_begin_pct).round; down_begin = 1 if down_begin == 0
		down_end = (@@height*down_end_pct).round
		if dimension_lock
			if @@width > @@height
				width = @@height
				right = (width*right_pct).round + ((@@width-@@height)/2).round
			elsif @@height > @@width
				height = @@width
				down_begin = (height*down_begin_pct).round + ((@@height-@@width)/2).round; down_begin = 1 if down_begin_pct == 0
				down_end = (height*down_end_pct).round + ((@@height-@@width)/2).round; down_end = @@height if down_end_pct == 1
			end
		end		
		(down_begin..down_end).each {|down| add_object(right, down, "║")}
	end

	def place_angle_falling_left_to_right(right_begin_pct,down_begin_pct,max_right_pct,max_down_pct,dimension_lock=false)
		width = @@width; height = @@height
		right = (@@width*right_begin_pct).round; right = 1 if right == 0
		down = (@@height*down_begin_pct).round; down = 1 if down == 0
		max_right_end = (width*max_right_pct).round
		max_down_end = (height*max_down_pct).round
		if dimension_lock
			if @@width > @@height
				width = @@height
				right = (width*right_begin_pct).round + ((@@width-@@height)/2).round
				max_right_end = (width*max_right_pct).round + ((@@width-@@height)/2).round
			elsif @@height > @@width
				height = @@width
				down = (height*down_begin_pct).round + ((@@height-@@width)/2).round
				max_down_end = (height*max_down_pct).round + ((@@height-@@width)/2).round
			end
		end
		until right == max_right_end || down == max_down_end
			add_object(right,down,"\\"); right+=1; down+=1
		end
	end

	def place_angle_falling_right_to_left(right_begin_pct,down_begin_pct,max_right_pct,max_down_pct,dimension_lock=false)
		width = @@width; height = @@height
		right = (@@width*right_begin_pct).round
		down = (@@height*down_begin_pct).round; down = 1 if down == 0
		max_right_end = (width*max_right_pct).round; max_right_end = 1 if max_right_end == 0
		max_down_end = (height*max_down_pct).round
		if dimension_lock
			if @@width > @@height
				width = @@height
				right = (width*right_begin_pct).round + ((@@width-@@height)/2).round
				max_right_end = (width*max_right_pct).round + ((@@width-@@height)/2).round
			elsif @@height > @@width
				height = @@width
				down = (height*down_begin_pct).round + ((@@height-@@width)/2).round
				max_down_end = (height*max_down_pct).round + ((@@height-@@width)/2).round
			end
		end
		until right == max_right_end || down == max_down_end
			add_object(right,down,"/"); right-=1; down+=1
		end
	end

	def place_angle_rising_left_to_right(right_begin_pct,down_begin_pct,max_right_pct,max_down_pct,dimension_lock=false)
		width = @@width; height = @@height
		right = (@@width*right_begin_pct).round; right = 1 if right == 0
		down = (@@height*down_begin_pct).round
		max_right_end = (width*max_right_pct).round
		max_down_end = (height*max_down_pct).round; max_down_end = 1 if max_down_end == 0
		if dimension_lock
			if @@width > @@height
				width = @@height
				right = (width*right_begin_pct).round + ((@@width-@@height)/2).round
				max_right_end = (width*max_right_pct).round + ((@@width-@@height)/2).round
			elsif @@height > @@width
				height = @@width
				down = (height*down_begin_pct).round + ((@@height-@@width)/2).round
				max_down_end = (height*max_down_pct).round + ((@@height-@@width)/2).round
			end
		end
		until right > max_right_end || down < max_down_end
			add_object(right,down,"/"); right+=1; down-=1
		end
	end

	def place_angle_rising_right_to_left(right_begin_pct,down_begin_pct,max_right_pct,max_down_pct,dimension_lock=false)
		width = @@width; height = @@height
		right = (@@width*right_begin_pct).round
		down = (@@height*down_begin_pct).round
		max_right_end = (width*max_right_pct).round; max_right_end = 1 if max_right_end == 0
		max_down_end = (height*max_down_pct).round; max_down_end = 1 if max_down_end == 0
		if dimension_lock
			if @@width > @@height
				width = @@height
				right = (width*right_begin_pct).round + ((@@width-@@height)/2).round
				max_right_end = (width*max_right_pct).round + ((@@width-@@height)/2).round
			elsif @@height > @@width
				height = @@width
				down = (height*down_begin_pct).round + ((@@height-@@width)/2).round
				max_down_end = (height*max_down_pct).round + ((@@height-@@width)/2).round
			end
		end

		until right < max_right_end || down < max_down_end
			add_object(right,down,"\\"); right-=1; down-=1
		end
	end

	def build_structures
		case @@structures
			when "spires"
				place_vertical_line(0.25, 0.5, 1)
				place_vertical_line(0.5 , 0.4, 1)
				place_vertical_line(0.75, 0.5, 1)		
			when "stairs"
				place_horizontal_line(0.01, 0.9, 0.2)
				place_horizontal_line(0.2,  0.8, 0.4)
				place_horizontal_line(0.4,  0.7, 0.6)
				place_horizontal_line(0.6,  0.6, 0.8)
				place_horizontal_line(0.8,  0.5, 0.99)
			when "tiers"
				place_horizontal_line(0   , 0.6 , 0.18)
				place_horizontal_line(0.4 , 0.6 , 0.6 )
				place_horizontal_line(0.81, 0.6 , 1   )
				place_horizontal_line(0.16, 0.85, 0.42)
				place_horizontal_line(0.58, 0.85, 0.83)
			when "upward staggered ladder"
				place_horizontal_line(0.4 , 0.23, 0.51)	
				place_horizontal_line(0.49, 0.39, 0.65)
				place_horizontal_line(0.3 , 0.57, 0.51)
				place_horizontal_line(0.49, 0.75, 0.8 )
				place_horizontal_line(0.17, 0.95, 0.53)
			when "downward staggered ladder"
				place_horizontal_line(0.05, 0.25, 0.53)	
				place_horizontal_line(0.49, 0.50, 0.85)
				place_horizontal_line(0.25, 0.70, 0.51)
				place_horizontal_line(0.49, 0.86, 0.70)
				place_horizontal_line(0.35, 0.99, 0.51)	
			when "high platform"
				place_horizontal_line(0.33, 0.4, 0.66)
			when "low platform"
				place_horizontal_line(0.33, 0.8, 0.66)
			when "platform and slides"
				place_horizontal_line(0.45, 0.95, 0.75)
				place_angle_rising_right_to_left(0.55, 0.7, 0.2, 0.3)
				place_angle_rising_left_to_right(0.5, 0.5, 0.8, 0.25)
			when "funnel"
      	place_angle_rising_right_to_left(0.47, 0.66, 0.1, 0.33)
      	place_angle_rising_left_to_right(0.53, 0.66, 0.9, 0.33)
			when "bottle"
				place_horizontal_line(0.35, 0.7, 0.65, "lock")	#bottom
				place_vertical_line(0.35, 0.5, 0.7, "lock")  #body side, left
				place_vertical_line(0.65, 0.5, 0.7, "lock")  #body side, right
				place_angle_rising_left_to_right(0.35, 0.5, 0.45, 0.4, "lock")  #shoulder, left
				place_angle_rising_right_to_left(0.65, 0.5, 0.55, 0.4, "lock")  #shoulder, right
				place_vertical_line(0.45, 0.3, 0.4, "lock")  #neck side, left
				place_vertical_line(0.55, 0.3, 0.4, "lock")  #neck side, right
				place_horizontal_line(0.45, 0.3, 0.45, "lock")	#lip, left
				place_horizontal_line(0.55, 0.3, 0.55, "lock")	#lip, right
      when "funnel and flask"
      	#funnel
      	place_angle_rising_right_to_left(0.47, 0.4, 0.07, 0.07, "lock")
      	place_angle_rising_left_to_right(0.53, 0.4, 0.93, 0.07, "lock")
      	place_vertical_line(0.47, 0.4, 0.45, "lock")
      	place_vertical_line(0.53, 0.4, 0.45, "lock")
      	#flask
      	place_horizontal_line(0.3, 0.9, 0.7, "lock")	#bottom
				place_vertical_line(0.3, 0.8, 0.9, "lock")  #body side, left
				place_vertical_line(0.7, 0.8, 0.9, "lock")  #body side, right
				place_angle_rising_left_to_right(0.3, 0.8, 0.45, 0.65, "lock")  #shoulder, left
				place_angle_rising_right_to_left(0.7, 0.8, 0.55, 0.65, "lock")  #shoulder, right
				place_vertical_line(0.45, 0.57, 0.65, "lock")  #neck side, left
				place_vertical_line(0.55, 0.57, 0.65, "lock")  #neck side, right
				place_horizontal_line(0.45, 0.57, 0.45, "lock")	#lip, left
				place_horizontal_line(0.55, 0.57, 0.55, "lock")	#lip, right
			when "leaking bucket"
				place_horizontal_line(0.33, 0.67, 0.67)
				place_vertical_line(0.33, 0.45, 0.67)
				place_vertical_line(0.67, 0.45, 0.67)
				remove_object((@@width*0.5).round, (@@height*0.67).round)
			when "chambers"
				place_horizontal_line(0, 0.4, 1)
				(rand 3..5).times { rand = rand(1..@@width); remove_object(rand,(@@height*0.4).round) }
				place_horizontal_line(0, 0.8, 1)
				(rand 3..5).times { rand = rand(1..@@width); remove_object(rand,(@@height*0.8).round) }
			when "house"
				place_vertical_line(0.25, 0.8, 1, "lock")  #wall, left
				place_vertical_line(0.75, 0.8, 1, "lock")  #wall, right
				place_angle_falling_right_to_left(0.49, 0.55, 0.22, 1, "lock")  #roof, right
				place_angle_falling_left_to_right(0.51, 0.55, 0.78, 1, "lock")  #roof, left
				place_vertical_line(0.49, 0.5, 0.55, "lock")  #chimney side, left
				place_vertical_line(0.51, 0.5, 0.55, "lock")  #chimney side, right
				place_horizontal_line(0.49, 0.5, 0.49, "lock")	#chimney lip, left
				place_horizontal_line(0.51, 0.5, 0.51, "lock")	#chimney lip, right		
				place_horizontal_line(0, 1, 1)	#ground
			when "spotify album cover box (@5x zoom)"
				(@@height-40..@@height).each {|down| add_object(1, down, "║")} #left
				(@@height-40..@@height).each {|down| add_object(79, down, "║")} #right
				(1..79).each {|right| add_object(right,@@height-40,"═")} #top
				(1..79).each {|right| add_object(right,@@height,"═")} #bottom
			when "lonely phone booth"
				place_vertical_line(0.4, 0.8, 1, "lock")  #left
				place_vertical_line(0.6, 0.8, 1, "lock")  #right	
				place_horizontal_line(0.4, 0.8, 0.6, "lock")	#top
				place_horizontal_line(0.4, 1, 0.6,"lock")	#bottom
			when "randomize"
				#platforms
				rand(0..2).times do
					pw = rand((@@width*0.05).round..(@@width*0.5).round)  #"platform width"
					psp = rand(1..@@width-pw)  #"platform start point" (from left)
					pdc = rand((@@height*0.333).round..@@height-3)  #"platform down coord"
					(psp..psp+pw).each {|right| add_object(right,pdc,"═")}
				end
				#spires
				rand(0..2).times do
					sh = rand((@@height*0.1).round..(@@height*0.5).round)  #"spire height"
					ssp = rand((@@height*0.1).round..@@height-sh)  #"spire start point" (from top)
					src = rand((@@width*0.05).round..(@@width*0.95).round)  #"spire right coord"
					(ssp..ssp+sh).each {|down| add_object(src,down,"║")}
				end
				#angles (descending left to right)
				rand(0..2).times do
					@@width < @@height ? al = rand((@@width*0.05).round..(@@width*0.9).round) : al = rand((@@height*0.05).round..(@@height*0.9).round) #angle length
					arc = rand(1..@@width-al)  #"angle starting right coord" (from upper left)
					adc = rand((@@height*0.1).round..@@height-al)  #"angle starting down coord" (from upper left)
					al.times {add_object(arc,adc,"\\"); arc+=1; adc+=1}
				end
				#angles (ascending left to right)
				rand(0..2).times do
					@@width < @@height ? al = rand((@@width*0.05).round..(@@width*0.9).round) : al = rand((@@height*0.05).round..(@@height*0.9).round) #angle length
					arc = rand(1..@@width-al)  #"angle starting right coord" (from lower left)
					adc = rand(al+1..@@height)  #"angle starting down coord" (from lower left)
					al.times {add_object(arc,adc,"/"); arc+=1; adc-=1}
				end
			when "randomized platforms"
				rand(2..4).times do
					pw = rand((@@width*0.05).round..(@@width*0.333).round)  #"platform width"
					psp = rand(1..@@width-pw)  #"platform start point" (from left)
					pdc = rand((@@height*0.25).round..@@height-3) #"platform down coord"
					(psp..psp+pw).each {|right| add_object(right,pdc,"═")}
				end	
		end
		mark_interior_spaces
	end

	def mark_interior_spaces
		(1..@@height).each { |down|
			(1..@@width).each { |right|
				if @@object_map[get_coord(right,down)] == "O"
					ob1_right = right
					ob2_right = "none"
					(ob1_right+1..@@width).each { |scan_right| ob2_right = scan_right if @@object_map[get_coord(scan_right,down)] == "O" }
					if ob2_right != "none"
						 (ob1_right..ob2_right).each { |int_right| @@object_map[get_coord(int_right,down)] = "x" if @@object_map[get_coord(int_right,down)] == " " }
					end
				end
			}
		}
	end

	def select_randomized_structures
		clear_window
		build_structures
		puts @@window
		answer = get_option_from_answer_to("Use these randomized structures or generate new? (\"use\"/\"new\")", "use", "new")
		select_randomized_structures if answer == "new"
		clear_screen
	end


	### SNOWFALL ###

	def update_window_coord(right,down,new_char)
		coord = get_coord(right,down)
		@@window[coord] = new_char
	end

	def accumulate(right,down)
		coord = get_coord(right,down)
		@@object_map[coord] = "A"
	end

	#by default checks whether a coordinate is occupied with anything at all (including window edges, excluding interior spaces); if a character is passed in as an optional third argument, checks whether the coordinate is occupied with that character specifically
	def coord_occupied?(right,down,character=false)
		coord = get_coord(right,down)
		if character 
			@@object_map[coord] == character
		else 
			@@object_map[coord] !~ /(\s|x)/ || right < 1 || right > @@width
		end
	end

	def drifting_flake?(right,down)
		coord = get_coord(right,down)
		@@object_map[coord] =~ /(\s|x)/ && (@@window[coord] == "." || @@window[coord] == "•" || @@window[coord] == "●")
	end


	### WINDOW ###

	def clear_screen
		defined?(@@height) ? @@height.times {puts "\n"} : 300.times {puts "\n"}
	end

	def clear_window
		@@window = (" " * @@width + "\n") * @@height
		@@object_map = (" " * @@width + "\n") * @@height
	end

	def display
		#puts @@object_map; sleep(0.3) #uncomment to view object map
		puts @@window; sleep(0.3)
		@@frame_count += 1

		# #For displaying info during snowfall: uncomment and reduce window height by 8
		# puts "total frames: " + @@frame_count.to_s
		# puts "flake count: " + @@flake_count.to_s
		# w = @@width; puts "current layer depth: " + (@@layer_size/w).to_s #'w' variable a workaround for sublime visualization bug
		# puts "current intensity level: " + @@intensity_level.to_s														
		# puts "current intensity period duration: " + @@intensity_duration.to_s 		
		# puts "current intensity period expiration: " + "-" + (@@intensity_expiration - Time.now).to_i.to_s 
		# puts "current breeze: " + @@breeze_now.to_s

	end

end





class Snowflake < Window

	attr_accessor :waiting, :done

	def initialize
		@@flake_count += 1
		@right = rand(1..@@width)
		@down = 1
		@@snow_layers == true ? @flake = @@layer_flake_array_now.sample : @flake = [".",".","•","●"].sample
		@activated = true
		@activation_time = Time.now
		@waiting = false
		set_intensity_exclusion
		@timer_last_set_for = "none"
		@done = false
	end

	def self.update_flake_count
		@@flake_count += 1
	end

	def self.new_layer
		@@layer_size = rand(2..8)*@@width
		@@layer_flake_count = 0
		@@layer_flake_array_now == @@layer_flake_array_1 ? @@layer_flake_array_now = @@layer_flake_array_2 : @@layer_flake_array_now = @@layer_flake_array_1
	end

	def set_intensity_exclusion
		# 95% of flakes are excluded during light intensity
		# 80% of flakes are excluded during moderate intensity
		# 0% of flakes are excluded during heavy intensity
		exclusion_level = rand
		if exclusion_level > 0.95
			@intensity_exclusion = ["none"]  
		elsif exclusion_level > 0.8
			@intensity_exclusion = ["omit from light"]  
		else
			@intensity_exclusion = ["omit from light","omit from moderate"]
		end
	end

	def self.new_intensity
		if @@intensity_level == "heavy"
			@@intensity_level = "moderate"
		elsif @@intensity_level == "moderate"
			@@intensity_level = ["heavy","light"].sample
		elsif @@intensity_level == "light"
			@@intensity_level = "moderate"
		end
		@@intensity_duration = rand(60..300) #1-5 minutes
		@@intensity_expiration = Time.now + @@intensity_duration         
	end

	def reset_flake
		if @@object_map.split("\n")[(@@height*0.25).round].count("A") >= @@width*0.666
			@done = true
		else
			Snowflake.update_flake_count
			@right = rand(1..@@width)
			@down = 1
			if @@snow_layers == true
				@@layer_flake_count += 1
				@flake = @@layer_flake_array_now.sample
				Snowflake.new_layer if @@layer_flake_count > @@layer_size
			end
		end
	end

	def reset_or_delay_flake
		reset_flake if @activated
		#delay deactivated flake if not already delayed
		if @activated == false && @waiting == false																
			@activation_time = Time.now + @@intensity_duration
			@timer_last_set_for = @@intensity_level
			@waiting = true
		end
	end

	def deactivate_flake_if_omitted
		#update flake when intensity changes
		if @@intensity_level == "moderate"      
			#deactivate flake if tagged with "omit from moderate"
			@activated = false if @intensity_exclusion.any? {|rule| rule == "omit from moderate" }
			#for light->moderate, update timer for flakes that are omitted from moderate intensity periods
			if @waiting && @timer_last_set_for == "light" && @intensity_exclusion.any? {|rule| rule == "omit from moderate" }
				@activation_time += @@intensity_duration
				@timer_last_set_for = "moderate"
			end
		elsif @@intensity_level == "light"
			#deactivate flake if tagged with "omit from light"
			@activated = false if @intensity_exclusion.any? {|rule| rule == "omit from light" }
			# for moderate->light, update timer for already-waiting flakes
			if @waiting && @timer_last_set_for == "moderate"
				@activation_time += @@intensity_duration
				@timer_last_set_for = "light"
			end
		end
	end

	def reactivate_and_reset_waiting_flake_if_time_to_reactivate
		#reactivate flake if time to reactivate
		if @waiting && Time.now >= @activation_time							
			@activated = true
			@waiting = false
			reset_flake
		end
	end

  #|   x ●        ● x 
  #|   x ◯   OR   ◯ x
	def flake_is_on_a_ledge?(right,down)																																																							 
		coord_occupied?(right,(down+1)) &&
		((!coord_occupied?((right-1),down) && !coord_occupied?((right-1),(down+1))) || (!coord_occupied?((right+1),down) && !coord_occupied?((right+1),(down+1)))) 
	end

  #|   ◯ ● x        x ● ◯ 
  #|     ◯ x   OR   x ◯
	def flake_is_on_a_slope?(right,down)																																	    
		coord_occupied?(right,(down+1)) && 
		( (coord_occupied?(right-1,down) && !coord_occupied?(right+1,down) && !coord_occupied?(right+1,down+1)) ||
		  (coord_occupied?(right+1,down) && !coord_occupied?(right-1,down) && !coord_occupied?(right-1,down+1)) )
	end

  #|   * ● x        x ● * 
  #|     ◯ x   OR   x ◯
	def flake_is_on_a_snow_slope?(right,down)																													    
		coord_occupied?(right,(down+1)) && 
		( (coord_occupied?(right-1,down,"A") && !coord_occupied?(right+1,down) && !coord_occupied?(right+1,down+1)) ||
		  (coord_occupied?(right+1,down,"A") && !coord_occupied?(right-1,down) && !coord_occupied?(right-1,down+1)) )
	end

  #|   \ ● x        x ● / 
  #|     \ x   OR   x /
	def flake_is_on_an_object_slope?(right,down)																																	    
		coord_occupied?(right,(down+1),"O") && 
		( (coord_occupied?(right-1,down,"O") && !coord_occupied?(right+1,down) && !coord_occupied?(right+1,down+1)) ||
		  (coord_occupied?(right+1,down,"O") && !coord_occupied?(right-1,down) && !coord_occupied?(right-1,down+1)) )
	end

  #|   ◯ ● x x        x x ● ◯
  #|     ◯ ◯ x   OR   x ◯ ◯
	def flake_is_on_a_shallow_slope?(right,down)
		coord_occupied?(right,down+1) &&
		( (coord_occupied?(right-1,down) && !coord_occupied?(right+1,down) && !coord_occupied?(right+2,down) && coord_occupied?(right+1,down+1) && !coord_occupied?(right+2,down+1)) ||	
			(coord_occupied?(right+1,down) && !coord_occupied?(right-1,down) && !coord_occupied?(right-2,down) && coord_occupied?(right-1,down+1) && !coord_occupied?(right-2,down+1)) )
	end

  #|   x ● x
  #|   x ◯ x
	def flake_is_on_a_pinnacle?(right,down)
		coord_occupied?(right,(down+1)) &&
		!coord_occupied?(right-1,down) && !coord_occupied?(right-1,down+1) &&
		!coord_occupied?(right+1,down) && !coord_occupied?(right+1,down+1) 
	end

  #|   ◯ ● ◯
  #|     ◯
	def flake_is_in_a_pocket?(right,down)
		coord_occupied?(right,(down+1)) && coord_occupied?((right-1),down) && coord_occupied?((right+1),down)
	end

	def drift_with_breeze(right,down)
		coord = @@object_map[get_coord(right,down)] 
		drift_num = rand
		if @@breeze_now == "none" || coord == "x"
			drift_num < 0.3333 ? drift = -1 : drift_num < 0.6666 ? drift = 0 : drift = 1
		else
			if @@breeze_now == "strong left" 
				drift_num < 0.9 ? drift = -1 : drift_num < 0.95 ? drift = 0 : drift = 1
			elsif @@breeze_now == "moderate left" 
				drift_num < 0.6 ? drift = -1 : drift_num < 0.8 ? drift = 0 : drift = 1
			elsif @@breeze_now == "light left"
				drift_num < 0.4 ? drift = -1 : drift_num < 0.7 ? drift = 0 : drift = 1
			elsif @@breeze_now == "light right"
				drift_num < 0.3 ? drift = -1 : drift_num < 0.6 ? drift = 0 : drift = 1
			elsif @@breeze_now == "moderate right"
				drift_num < 0.2 ? drift = -1 : drift_num < 0.4 ? drift = 0 : drift = 1
			elsif @@breeze_now == "strong right"
				drift_num < 0.05 ? drift = -1 : drift_num < 0.1 ? drift = 0 : drift = 1
			end
		end
		drift
	end

	def fall

		unless @waiting || @done
			#CONDITIONS FOR LANDING
			#if a flake has reached the bottom of the window, it either lands or disappears depending on the user-defined base accumulation settings
			if @down == @@height
				@@accumulate_at_base ? accumulate(@right,@down) : update_window_coord(@right,@down," ")
				reset_or_delay_flake
			#otherwise, if the flake has fallen into a pocket, it lands
			elsif flake_is_in_a_pocket?(@right,@down) || 
						#or, if it falls on a fixed object, and not on a ledge, and not on a shallow slope (90% of the time), it lands
				    (coord_occupied?(@right,@down+1) && !flake_is_on_a_ledge?(@right,@down) && !(flake_is_on_a_shallow_slope?(@right,@down) && rand<0.9)) || 
						#or, if it falls on a snow slope, it lands .5% of the time (this allows flake occasionally to catch on a snow slope to avoid uniform pyramids)
						(flake_is_on_a_snow_slope?(@right,@down) && rand<0.005) ||
						#or, if it falls on an object slope, it lands .5% of the time depending on user-defined object accumulation settings
						(flake_is_on_an_object_slope?(@right,@down) && rand<0.005 && !@@slippery_objects)
				accumulate(@right,@down) 
				reset_or_delay_flake
			#otherwise, the flake drifts depending on its surroundings and the breeze...	

			#CONDITIONS FOR CONTINUING TO FALL
			elsif !@waiting
				update_window_coord(@right,@down," ")
				#if a flake has reached a pinnacle, it drifts to either side
				if flake_is_on_a_pinnacle?(@right,@down) 
					rand < 0.5 ? drift = -1 : drift = 1
				#if a flake has reached a ledge or slope, it drifts down it
				elsif flake_is_on_a_ledge?(@right,@down) && coord_occupied?(@right-1,@down+1) ||    #|    ●>x    /  ◯ ●>x          x<●      /  x<● ◯
							flake_is_on_a_slope?(@right,@down) && coord_occupied?(@right-1,@down)         #|  ◯ ◯ x   /     ◯ x    OR    x ◯ ◯   /   x ◯
					 drift = 1																																				#|         /        ◯                 /    ◯
				elsif flake_is_on_a_ledge?(@right,@down) && coord_occupied?(@right+1,@down+1) ||
							flake_is_on_a_slope?(@right,@down) && coord_occupied?(@right+1,@down)
					 drift = -1
				#if a flake is on a shallow slope, it drifts down it (makes slopes slipperier so more likely to accumulate in troughs) 
				elsif flake_is_on_a_shallow_slope?(@right,@down) && coord_occupied?(@right-1,@down)	  #|  ◯ ●>x x   /  x x<● ◯
					drift = 1                                                                           #|    ◯ ◯ x  /   x ◯ ◯
				elsif flake_is_on_a_shallow_slope?(@right,@down) && coord_occupied?(@right+1,@down)
					drift = -1
				#othwerwise, if a flake is still in the air, it just drifts with the breeze
				else
					drift = drift_with_breeze(@right,@down)
				end
				#the flake falls downward most of the time (unless it's on a shallow slope and can't), but not all, to create a drift effect
				rand < 0.9 && !flake_is_on_a_shallow_slope?(@right,@down) ? fall = 1 : fall = 0
				test_right = @right+drift
				test_down = @down+fall
				if @@universe == "infinite" 
					#loops the universe horizontally so drifting flakes pass behind window edges (and re-appear on the opposite side)
					if test_right > @@width
						if coord_occupied?(1,test_down)
							reset_flake; return
						else
							test_right = 1
						end
					elsif test_right < 1
						if coord_occupied?(@@width,test_down) 
							reset_flake; return
						else
							test_right = @@width
						end
					end
				elsif @@universe == "snow globe"
					#treats window edges as walls
					test_right = @@width if test_right >= @@width+1
					test_right = 1 if test_right <= 0
				end
				#assign new flake position only if flake wouldn't drift into another drifting flake, accumulated flake, or object
				unless drifting_flake?(test_right,test_down) || coord_occupied?(test_right,test_down)
					@right = test_right 
					@down = test_down
				#otherwise, assign new flake position with fall only, unless something's in the way below it
				else
					@right = @right
					drifting_flake?(@right,test_down) || coord_occupied?(@right, test_down) ? @down = @down : @down = test_down
				end
				update_window_coord(@right,@down,@flake)
			end
		end	

		#Update breeze if time to update
		update_breeze
		#Update intensity if time to update
		update_intensity
		#Deactivate/update flake if omitted from current intensity level
		deactivate_flake_if_omitted
		#Reactivate flake if time to reactivate
		reactivate_and_reset_waiting_flake_if_time_to_reactivate

	end


end





class Snow < Window

	def initialize
		Window.new
		@@snowflakes = []
		@@width > @@height ? @@width.times { @@snowflakes << Snowflake.new } : @@height.times { @@snowflakes << Snowflake.new }
		begin_snowfall
		continue_snowfall
	end

	def begin_snowfall
		#first flakes: one released every fifth frame, five times
		(1..5).each {|item| 5.times { item.times { |s| @@snowflakes[s-1].fall }; display } }
		#rest of flakes: five released every fifth frame until last flake released
		(2..(@@snowflakes.count/5)).inject(0) do |accumulator,item|
			5.times { (item*5).times { |s| @@snowflakes[s-1].fall }; display }
		end
	end

	def continue_snowfall
		until @@snowflakes.all? {|flake| flake.done || flake.waiting}
			@@snowflakes.each {|flake| flake.fall }; display
		end
	end

end




Snow.new



