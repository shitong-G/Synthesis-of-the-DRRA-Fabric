#1. This tiny bash script is for automation of placing and routing the partitions.
#2. Instead of place and routing the six paritions one by one, you can use this script.
#3. The script simply triggers pnr_partition.tcl script for all the partitions in the part directory at once.
#4. It is not required to use this script for this project. But interested students can use it and see the benefits of automating tasks.
#5. Feel free to use Google or ChatGPT to understand the commands :)

# Resolve paths so the script can be run from anywhere (e.g. phy/scr)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"
PART_DIR="${PROJECT_ROOT}/phy/db/part"
LOG_DIR="${PROJECT_ROOT}/log"

# Provide defaults if not exported by caller
if [ -z "${TOP_NAME}" ]; then
	TOP_NAME="drra_wrapper"
fi
if [ -z "${TIMESTAMP}" ]; then
	TIMESTAMP=$(date +%Y%m%d_%H%M%S)
fi

partition_list="$(ls "${PART_DIR}"/*enc 2>/dev/null | grep -v "${TOP_NAME}")"
pids=()

if [ -z "${partition_list}" ]; then
	echo "No partitions found under ${PART_DIR}. Check that create_partitions.tcl ran successfully."
	exit 1
fi

for partition in ${partition_list}
do
	filename=$(basename -- "$partition")
	extension="${filename##*.}"
	filename="${filename%.*}"
	cd "${partition}.dat" || exit 1
	rm -rf pnr 
	mkdir pnr 
	innovus -stylus -no_gui -batch -files "${PROJECT_ROOT}/phy/scr/pnr_partition.tcl" -log "${LOG_DIR}/pnr_${filename}_${TIMESTAMP}.log ${LOG_DIR}/pnr_part_${filename}_${TIMESTAMP}.cmd ${LOG_DIR}/pnr_part_${filename}_${TIMESTAMP}.logv" &
	pids+=($!)
	cd "${PROJECT_ROOT}/phy/scr" || exit 1
done

wait "${pids[@]}"