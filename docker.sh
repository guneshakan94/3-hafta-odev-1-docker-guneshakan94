RUN="docker container run -d -p 80:5000"
usage () {
echo "Usage:
    --mode              Select mode <build|deploy|template> 
    --image-name        Docker image name
    --image-tag         Docker image tag
    --memory            Container memory limit
    --cpu               Container cpu limit
    --container-name    Container name
    --registry          DocherHub or GitLab Image registry <docker.io|gitlap_address>
    --application-name  Run mysql or mongo server
    --help              How to use this script"
}
###################################Spesift-Mode###########################################
mode (){
    if [[ "$MODE" == build ]]; then
        build
    elif [[ "$MODE" == deploy ]]; then
        deploy
    elif [[ "$MODE" == template ]]; then
        template
    else
       echo "You must spesify the mode! <build/deploy/template>
See 'docker.sh --help'"
    fi
}
###################################Docker-Build###########################################
build (){
    if [[ -n "$IMAGE" ]] && [[ -n "$TAG" ]] && [[ -n "$REGISTRY" ]]; then
        docker image build -t "$IMAGE":"$TAG" .
        docker login
        docker image push "$IMAGE":"$TAG"
    elif [[ -n "$IMAGE" ]] && [[ -n "$TAG" ]]; then
        docker image build -t "$IMAGE":"$TAG" .
    else 
        echo "You must specisfy the image-name and image-tag!" 
        exit 1
    fi
}
##################################Database-Build############################################
template (){
    if [[ "$APPLICATION" == mongo ]]; then
        docker-compose -f mongo-docker-compose.yaml build
        docker-compose -f mongo-docker-compose.yaml up
    elif [[ "$APPLICATION" == mysql ]]; then
        docker-compose -f mysql-docker-compose.yaml build
        docker-compose -f mysql-docker-compose.yaml up
    fi

}
###################################Giving-Arguments###########################################
deploy (){    
    if [[ -n "$IMAGE" ]] && [[ -n "$TAG" ]]; then
        eval $RUN $IMAGE:$TAG     
    else
        echo "You must specisfy the image-name and image-tag!"
    fi
}
###################################Docker-Build###########################################
VALID_ARGS=$(getopt -o a:b:c:d:e:f:g:i:h:: --long image-name:,container-name:,mode:\
,memory:,cpu:,image-tag:,registry:,application-name:,help:: -- "$@")

if [[ -z $* ]]; then
    echo "You must spesify the mode! <build/deploy/template>
See 'docker.sh --help'"
    exit 1
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    --image-name)
        IMAGE="$2"
        shift 2
        ;;
    --image-tag)
        TAG="$2"
        shift 2
        ;;    
    --container-name)
        CONTNAME="$2"
        if [[ -n $2 ]]; then
        RUN+=" --name $2"
        fi
        shift 2
        ;;
    --mode)
        MODE="$2"
        shift 2
        ;;
    --memory)
        MEM="$2"
        if [[ -n $2 ]]; then
        RUN+=" --memory $2"
        fi
        shift 2
        ;;
    --cpu)
        CPU="$2"
        if [[ -n $2 ]]; then
        RUN+=" --cpus $2"
        fi
        shift 2
        ;;
    --registry)
        REGISTRY="$2"
        shift 2
        ;;
    --application-name)
        APPLICATION="$2"
        shift 2
        ;;
    --help)
        usage;
        exit 1
        ;;
    --) shift; 
        break 
        ;;
  esac
done
###################################Run-Fonctuion###########################################
mode