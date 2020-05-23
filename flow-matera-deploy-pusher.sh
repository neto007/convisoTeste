#!/bin/bash
CURRENT_TAG=$(git ls-remote -q  --tags | awk '{print $2}' | grep -E 'conviso-[0-9]' | sed 's@refs/tags/@@'| tail -n1)
PREVIOUS_TAG=$(git ls-remote -q  --tags | awk '{print $2}'  | grep -E 'conviso-[0-9]' | sed 's@refs/tags/@@' | tail -n2 | head -n1)
CHANGED_FILES=$(git diff --name-only ${CURRENT_TAG} ${PREVIOUS_TAG} | tr '\n' ',')

echo $CURRENT_TAG
echo $PREVIOUS_TAG

API_CODE=$1

case "$2" in
  development )
    URL=http://localhost:3000/api/v2/deploys
    ;;
  staging )
    URL=https://homologa.conviso.com.br/api/v2/deploys
    ;;
  * )
    URL=https://app.conviso.com.br/api/v2/deploys
esac

create_post_data()
{
  cat << EOF
{  
   "deploy":{  
      "current_tag":"${CURRENT_TAG}",
      "previous_tag":"${PREVIOUS_TAG}"
   },
   "api_code":"${API_CODE}",
   "changed_files":"${CHANGED_FILES// /_}"
}
EOF
}

echo $(create_post_data) | curl -X POST $URL -H "Content-Type: application/json" -d @-