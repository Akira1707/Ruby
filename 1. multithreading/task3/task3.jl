using CSV
using DataFrames
using JSON
using Distributed

# Add all available CPU threads for parallel processing
addprocs()

@everywhere begin
    using CSV
    using DataFrames
    using Statistics 
end

# Function to process a single CSV file
@everywhere function process_file(file_path)
    df = CSV.read(file_path, DataFrame)
    avg_temp = mean(df.temperature)
    avg_humidity = mean(df.humidity)
    return Dict(
        "file" => file_path,
        "average_temperature" => avg_temp,
        "average_humidity" => avg_humidity
    )
end

# Main program
function main()
    # Directory containing CSV files
    data_dir = "sensor_data"
    files = readdir(data_dir; join=true)
    csv_files = filter(f -> endswith(f, ".csv"), files)

    # Process files in parallel
    results = pmap(process_file, csv_files)

    # Calculate overall averages
    total_temp = mean([r["average_temperature"] for r in results])
    total_humidity = mean([r["average_humidity"] for r in results])

    overall = Dict(
        "overall_average_temperature" => total_temp,
        "overall_average_humidity" => total_humidity
    )

    # Save results
    json_str = JSON.json(Dict("per_file" => results, "overall" => overall))

    open("sensor_report.json", "w") do io
        write(io, json_str)
    end


    println("Sensor analysis complete. Report saved to sensor_report.json")
end

main()

