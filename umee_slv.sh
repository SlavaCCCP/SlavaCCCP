#!/bin/bash

WALLETS=(
"umee1rzptz5rapy5yctj0hskn5p3wt6kwqsmecs9s5u"
"umee1rzptz5rapy5yctj0hskn5p3wt6kwqsmecs9s5u"
)
WALLETS_PASSWORD=
TARGET_WALLET=umee1sgaxw6wdt032s3762gutpxh29faphtc2t6wqgv

DELAY_TIME=21600
RPC=http://178.170.49.138:26657/
UMEE_CHAIN="umee-1"
FEES=0
MSG=1

function senditshit(){
	for item in ${WALLETS[*]}; do
		echo -e ""
		echo -e "Working with ${item}"
		echo -e "Trying to claim rewards..."
		while [ $MSG -ne 0 ]; do
			MSG=$(echo -e "${WALLETS_PASSWORD}\n" | $(which umeed) tx distribution withdraw-all-rewards --from=${item} --chain-id=${UMEE_CHAIN} --fees=${FEES}uumee --node ${RPC} -y) &>> umee_slv.logs
			MSG=$(echo $MSG | grep -Eo "code: [0-9]+" | grep -Eo "[0-9]+")  
			if [ $MSG -eq 0 ]; then
				echo -e "Successfully withdraw rewards from commission!"
			else
				echo -e "Failed to withdraw rewards from commission. Retry in 10 sec..."
		fi
		sleep 10
		done
		MSG=1
		
		echo -e "Checking available balance for ${item}..."
		RESULT_2=0
		while [ $RESULT_2 -ne 5 ]; do
			RESULT=$(echo -e "${WALLETS_PASSWORD}\n" | $(which umeed) tx bank send $item $TARGET_WALLET 10000000000uumee --chain-id=${UMEE_CHAIN} --fees ${FEES}uumee --node ${RPC} -b block -y)
			RESULT_2=$(echo $RESULT | grep -Eo "code: [0-9]+" | grep -Eo "[0-9]+")
			if [ $RESULT_2 -eq 5 ]; then
				RESULT=$(echo $RESULT | grep -Eo "[0-9]+uumee is smaller" | grep -Eo "[0-9]+")
			else 
				echo -e "failed to check available balance. Retry in 5 sec..."
				sleep 5
			fi
		done
    echo -e "Success! Total ${RESULT}uumee available for send. Trying to send uumee to ${TARGET_WALLET}"
    sleep 10
		MSG=1
		
		while [ $MSG -ne 0 ]; do
			MSG=$(echo -e "${WALLETS_PASSWORD}\n" | $(which umeed) tx bank send $item $TARGET_WALLET ${RESULT}uumee --chain-id=${UMEE_CHAIN} --fees ${FEES}uumee --node ${RPC} -y) &>> umee_slv.logs
			MSG=$(echo $MSG | grep -Eo "code: [0-9]+" | grep -Eo "[0-9]+")
			if [ $MSG -eq 0 ]; then
				echo -e "Successfully sended ${RESULT}uumee to ${TARGET_WALLET}!"
			else
				echo -e "Failed to send ${RESULT}uumee to ${TARGET_WALLET}. Retry in 10 sec..."
				RESULT=10000000
			fi	
		sleep 10
		done
		MSG=1
done
}

while true; do
  senditshit
  echo -e "Sleep ${DELAY_TIME} sec."
  sleep $DELAY_TIME
done