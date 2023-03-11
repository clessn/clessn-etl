#!/bin/sh

foldername="clessn-blend/pipelines/extractors"
scriptname="e_eu_parliament_plenary"

echo "Extracting Europe national assembly"

generate_post_data()
{
  cat <<EOF
  {
   "text": "\n${status}: ${scriptname} ${output_msg} on $(date)\n${output}\n"
  }
EOF
}

R --no-save --no-reestore -e 'install.packages("remotes", repos = "http://cran.us.r-project.org")'
R --no-save --no-restore -e 'remotes::install_github("clessn/clessnverse", force=T, upgrade="never")'

cd ~

if [ $scriptname != "badbadbad" ]; then
  Rscript --no-save --no-restore $CLESSN_ROOT_DIR/$foldername/$scriptname.R --log_output $2 --backend $3 --schema $4 --refresh $5 --method $6 --translate $7 2>&1
  ret=$?
  sed 's/\"/\\"/g' -i ~/logs/$scriptname.log
  sed 's///g ' -i ~/logs/$scriptname.log
  sed 's/--:--/     /g ' -i ~/logs/$scriptname.log
  sed 's/:--/   /g ' -i ~/logs/scriptname.log
fi


if [ $ret -eq 0 ]; then
  status="SUCCESS"
  output_msg="completed successfully"
fi

if [ $ret -eq 1 ]; then
  status="ERROR"
  output_msg="generated one or more errors"
fi

if [ $ret -eq 2 ]; then
  status="WARNING"
  output_msg="generated one or more warnings"
fi

if [ $ret -ne 0 ]; then
  output=`tail -n 10 ~/logs/$scriptname.log`
  curl -X POST -H 'Content-type: application/json' --data "$(generate_post_data)" https://hooks.slack.com/services/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
else
  output=`tail -n 2 ~/logs/$scriptname.log`
  curl -X POST -H 'Content-type: application/json' --data "$(generate_post_data)" https://hooks.slack.com/services/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
fi
