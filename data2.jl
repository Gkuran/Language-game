using XLSX, CSV, DataFrames

file = "$( @__DIR__ )/datasets/dist_cepii.xlsx"

# -------------------------------------------------------------------
# READ EXCEL
# -------------------------------------------------------------------

xf = XLSX.readxlsx(file)
sh = xf["dist_cepii"]
df = DataFrame(XLSX.gettable(sh))

println(names(df))

# -------------------------------------------------------------------
# SELECT BORDER RELATIONSHIP DATA
# -------------------------------------------------------------------

iso_o_col = :iso_o   # country 1
iso_d_col = :iso_d   # country 2
cont_col  = :contig  # 1 = share border, 0 = no border

# -------------------------------------------------------------------
# BUILD BORDER EDGE LIST
# -------------------------------------------------------------------

data = DataFrame(
    iso1 = df[!, iso_o_col],
    iso2 = df[!, iso_d_col],
    contig = df[!, cont_col]
)

# -------------------------------------------------------------------
# KEEP ONLY BORDERS (contig = 1)
# -------------------------------------------------------------------

filter!(row -> row.contig == 1, data)
filter!(row -> row.iso1 != row.iso2, data)


sort!(data, [:iso1, :iso2])
CSV.write("borders.csv", data)

println("Saved borders.csv with $(nrow(data)) country pairs")