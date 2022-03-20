export PYTHON_ENV_DIR=/data/python-env

activate() {
    DIR=$1
    declare -f deactivate > /dev/null && deactivate
    if [[ -z $1 ]]; then
    	cloudstackversion=`cat pom.xml | sed -r '1,50s/xmlns(:[^=]+)?=".*"//g' | sed '2,50s/xsi:schemaLocation=".*"//g' | xmllint --xpath '/project/version/text()' -`
	if [[ $cloudstackversion =~ "4.3" ]];   then DIR=acs4.3
        elif [[ $cloudstackversion =~ "4.5" ]]; then DIR=acs4.5
        elif [[ $cloudstackversion =~ "4.11" ]]; then DIR=acs4.11
        else DIR=acsmaster
        fi
    fi
    source "$PYTHON_ENV_DIR/$DIR/bin/activate"
}


_activate() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( basename -a `ls -d $PYTHON_ENV_DIR/$cur*` | tr '\n' ' ') )
}

complete -F _activate activate

_acs() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
      deploy)
        COMPREPLY=( $(ls setup/dev/$cur*.json | cut -d/ -f 3 | cut -d'.' -f 1 | tr '\n' ' ') )
        ;;
      *)
        COMPREPLY=( $(compgen -W "deploy create-db clear-db run run-sim debug debug-sim install-marvin" -- $cur) )
    esac
}

complete -F _acs acs

acs() {
    export REBEL_BASE=/home/fmaximus/.jrebel
    export REBEL_HOME=/home/fmaximus/.IntelliJIdea2017.2/config/plugins/jr-ide-idea/lib/jrebel6
    REBEL_OPTIONS="-agentpath:$REBEL_HOME/lib/libjrebel64.so"
    DEFAULT_MAVEN_OPTS="-Xmx812m -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.local.only=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
    MAVEN_DEBUG_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n"
    case "$1" in
      clear-db)
        mvn install -pl developer -Ddeploydb -o && mvn install -pl developer -Ddeploydb-simulator -o
        ;;
      create-db)
        shift
        if [ -f utils/conf/db.properties.override ]; then 
          ROOT_PASSWORD=`grep db.root.password utils/conf/db.properties.override | cut -f2 -d=`
        else
          ROOT_PASSWORD=12345678
          cp utils/conf/db.properties utils/conf/db.properties.override
          sed -i "/db.root.password/s/\$/$ROOT_PASSWORD/" utils/conf/db.properties.override
        fi
        docker run --name mysql_$1 -e MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD -e MYSQL_ROOT_HOST='%' -p 3306:3306 -d mysql/mysql-server:5.5  
        unset ROOT_PASSWORD
        ;;
      run-sim)
        shift
        MAVEN_OPTS=${DEFAULT_MAVEN_OPTS} mvn -pl client jetty:run -Dsimulator -o  $*
        ;;
      run)
        shift
        MAVEN_OPTS=${DEFAULT_MAVEN_OPTS} mvn -pl client jetty:run -o $*
        ;;
      debug-sim)
        shift
        MAVEN_OPTS="${DEFAULT_MAVEN_OPTS} ${MAVEN_DEBUG_OPTS}" mvn -pl client jetty:run -Dsimulator -o $*
        ;;
      debug)
        shift
        MAVEN_OPTS="${DEFAULT_MAVEN_OPTS} ${MAVEN_DEBUG_OPTS}" mvn -pl client jetty:run -o $*
        ;;

      deploy)
        python tools/marvin/marvin/deployDataCenter.py -i setup/dev/$2.*
        ;;
      ri-build)
        mvn install -pl `git status --porcelain | grep -v '??' | grep "/src/" | cut -c4- | awk -F "/src/" '{print $1}' | uniq | tr '\n' ','`
        ;; 
      install-marvin)
        mvn install -pl tools/marvin
        if pip freeze | grep -q Marvin
        then pip uninstall -y marvin
        fi
        tux exec pip install `ls tools/marvin/dist/Marvin*`[nuagevsp]
        ;;
      *)
        echo "Usage: acs [clear-db|run|deploy|install-marvin]"
        ;;
    esac

    unset DEFAULT_MAVEN_OPTS
    unset MAVEN_DEBUG_OPTS
}

_tux() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "on off exec status" -- $cur) )
}

complete -F _tux tux

tux() {
    case "$1" in
    on)
    	#export {http,https}_proxy=http://proxy.lbs.alcatel-lucent.com:8000
    	export {http,https}_proxy=http://135.245.192.7:8000
        ;;
    off)
        unset {http,https}_proxy
        ;;
    exec)
    	#export {http,https}_proxy=http://proxy.lbs.alcatel-lucent.com:8000
    	export {http,https}_proxy=http://135.245.192.7:8000
        shift
        $*
        unset {http,https}_proxy
        ;;
    *)
        if (set | grep -q "^http_proxy=")
          then echo "on"
          else echo "off"
        fi
    esac
}
