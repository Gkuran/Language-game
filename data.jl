
using XLSX, CSV, DataFrames

file = "$( @__DIR__ )/datasets/geo_cepii.xlsx"   # path to your file

# -------------------------------------------------------------------
# READ EXCEL
# -------------------------------------------------------------------

xf = XLSX.readxlsx(file)
#println(XLSX.sheetnames(xf))
sh = xf["geo_cepii"]
df = DataFrame(XLSX.gettable(sh))

println(names(df))

# -------------------------------------------------------------------
# SELECT & RENAME COLUMNS
# (adjust names if needed after inspection)
# -------------------------------------------------------------------
name_col = :country
iso_col  = :iso3
lat_col  = :lat
lon_col  = :lon
area_col = :area

# -------------------------------------------------------------------
# BUILD CLEAN DATAFRAME
# -------------------------------------------------------------------

clean = DataFrame(
    name = df[!, name_col],
    iso  = df[!, iso_col],
    lat  = df[!, lat_col],
    lon  = df[!, lon_col],
    area = df[!, area_col]
)

# -------------------------------------------------------------------
# FILTER INVALID ROWS
# -------------------------------------------------------------------

filter!(row ->
    !ismissing(row.iso) &&
    !ismissing(row.lat) &&
    !ismissing(row.lon) &&
    row.iso != "", clean)

# -------------------------------------------------------------------
# SAVE CSV
# -------------------------------------------------------------------

sort!(clean, :name)
CSV.write("countries.csv", clean)
println("Saved countries.csv with $(nrow(clean)) countries")

