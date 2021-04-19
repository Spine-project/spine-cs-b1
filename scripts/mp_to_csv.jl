
using InfrastructureModels

IM = InfrastructureModels

file = ARGS[1]

mp_data = open(file) do io
	data_string = read(io, String)
	# We need to manually patch `data_string` by inserting '%column_names%' where needed.
	# This is because `PowerModels.export_matpower()` doesn't write it,
	# whereas `InfrastructureModels.parse_matlab_string()` expects it...
	data_lines = split(data_string, '\n')
	for (k, line) in enumerate(data_lines)
		# This below is just a dirty condition that works for the files in this project
		# I don't guarantee that it will work for *any* .m file
		if k > 1 && startswith(line, "%") && startswith(data_lines[k - 1], "%%")
			data_lines[k] = "%column_names%" * line[2:end]
		end
	end
	data_string = join(data_lines, '\n')
	matlab_data, func_name, colnames = IM.parse_matlab_string(data_string, extended=true)
	# write CSVs
	for key in ("bus", "gen", "branch")
		mpckey = "mpc.$key"
		outfile = "$key.csv"
		open(outfile, "w") do f
			column_names = colnames[mpckey]
			if key in ("gen", "branch")
				pushfirst!(column_names, "$(key)_name")
			end
			println(f, join(column_names, ", "))
			for (i, row) in enumerate(matlab_data[mpckey])
				if key in ("gen", "branch")
					row = string.(row)
					pushfirst!(row, "$(key)_$i")
				end
				str_row = join(row, ", ")
				println(f, str_row)
			end
		end
	end
end