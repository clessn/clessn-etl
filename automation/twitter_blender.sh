#!/bin/sh

foldername="clessn-blend/scrapers/twitter_blender"

generate_post_data()
{
  cat <<EOF
  {
    "text": "\n.\n${scriptname}\n============ start of message ============\n${status}: ${scriptname} $3 ${output_msg} on $(date)\nEXIT CODE: ${ret}\n${output}\n============ end of message ============\n.\n.\n "
  }
EOF
}

scriptname="twitter_blender.R"

R --no-save --no-restore -e 'install.packages("remotes", repos = "http://cran.us.r-project.org")'
R --no-save --no-restore -e 'remotes::install_github("clessn/clessnverse", ref="v1", force=T)'

R --no-save --no-restore -e 'remotes::install_url("https://cran.r-project.org/src/contrib/Archive/rtweet/rtweet_0.7.0.tar.gz", force=T)'

cd ~

Rscript --no-save --no-restore $CLESSN_ROOT_DIR/$foldername/$scriptname -m $1 -o $2 -t $3 -s $4 -f $5 1> "$scriptname.out"

ret=$?

sed 's/\"/\\"/g' -i $scriptname.out
sed 's/^M//g ' -i $scriptname.out
output=`cat $scriptname.out`

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
  curl -X POST -H 'Content-type: application/json' --data "$(generate_post_data)" https://hooks.slack.com/services/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
else
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${status}: ${scriptname} $3 ${output_msg} on $(date)\n\"}" https://hooks.slack.com/services/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
fi

if [ -f "$scriptname.out" ]; then
  rm -f "$scriptname.out"
fi
