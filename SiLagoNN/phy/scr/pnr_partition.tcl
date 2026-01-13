#1. cd into the specific partition
# cd ../phy/db/part/
#3. read the parition
read_db .
#4. place
place_design
#5. ccopt
ccopt_design
#6. route
route_design
#7. write the partition db
write_db ./pnr/
#8. write ilm
write_ilm