# Database utilities
if (( $+commands[psql] )); then
    function pgexec() {
        local db=${1:?Database required}
        local query=${2:?Query required}
        psql -d "$db" -c "$query"
    }
    
    function pgtables() {
        local db=${1:?Database required}
        psql -d "$db" -c '\dt'
    }
fi

if (( $+commands[mysql] )); then
    function myexec() {
        local db=${1:?Database required}
        local query=${2:?Query required}
        mysql -D "$db" -e "$query"
    }
    
    function mytables() {
        local db=${1:?Database required}
        mysql -D "$db" -e 'SHOW TABLES'
    }
fi

# AWS CLI helpers (if available)
if (( $+commands[aws] )); then
    function aws-profile() {
        export AWS_PROFILE="${1:?Profile required}"
        echo "AWS_PROFILE set to: $AWS_PROFILE"
    }
    
    function aws-regions() {
        aws ec2 describe-regions --query 'Regions[].RegionName' --output text
    }
    
    function aws-instances() {
        aws ec2 describe-instances \
            --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
            --output table
    }
fi

# Redis utilities
if (( $+commands[redis-cli] )); then
    function redis-keys() {
        redis-cli --scan --pattern "${1:-*}"
    }
    
    function redis-flush() {
        echo "Flushing Redis cache..."
        redis-cli FLUSHALL
    }
fi
