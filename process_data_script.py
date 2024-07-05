import csv


with open("data.csv", "r") as csv_origin_file:
    csv_reader = csv.DictReader(csv_origin_file)

    #titles of relevant columns
    titles = ["time", "ax", "ay", "az", "wx", "wy", "wz"]

    with open("small_data.csv", "w") as new_file:
        csv_writer = csv.DictWriter(new_file, fieldnames=titles, lineterminator="\n")

        #include headers in new file
        csv_writer.writeheader()


        prev_sample_time: float= 0

        #define samples pace - freq [HZ]
        samples_freq = 100
        samples_time_gap = 1/samples_freq

        for line in csv_reader:
            if "time" in line:
                try:
                    if float(line["time"]) - prev_sample_time >= samples_time_gap:
                        filtered_line = {key: value for key, value in line.items() if key in titles}
                        csv_writer.writerow(filtered_line)
                        prev_sample_time = float(line["time"])
                except ValueError as e:
                    print(f"Error processing line: {line}")
                    print(f"ValueError: {e}")
            else:
                print(f"Missing 'time' key in line: {line}")

    
