# ~/.core/zsh/integrations/kubernetes.zsh
# Kubernetes Integration - kubectl aliases, context management, and cluster helpers

#=============================================================================
# CHECK FOR KUBECTL
#=============================================================================
(( $+commands[kubectl] )) || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export KUBECONFIG="${KUBECONFIG:-$XDG_CONFIG_HOME/kube/config}"

# Create kube directory if needed
[[ -d "${KUBECONFIG%/*}" ]] || mkdir -p "${KUBECONFIG%/*}"

#=============================================================================
# LAZY-LOAD COMPLETION
# Kubectl completion is loaded on first use for faster startup
#=============================================================================
function kubectl() {
    unfunction kubectl 2>/dev/null
    source <(command kubectl completion zsh)
    command kubectl "$@"
}

#=============================================================================
# BASE ALIASES
#=============================================================================
alias k='kubectl'
alias kc='kubectl'

#=============================================================================
# GET OPERATIONS
#=============================================================================
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgpw='kubectl get pods -o wide'
alias kgpaw='kubectl get pods -A -o wide'
alias kgs='kubectl get services'
alias kgsa='kubectl get services -A'
alias kgd='kubectl get deployments'
alias kgda='kubectl get deployments -A'
alias kgrs='kubectl get replicasets'
alias kgss='kubectl get statefulsets'
alias kgds='kubectl get daemonsets'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress -A'
alias kgn='kubectl get nodes'
alias kgnw='kubectl get nodes -o wide'
alias kgns='kubectl get namespaces'
alias kgj='kubectl get jobs'
alias kgcj='kubectl get cronjobs'
alias kga='kubectl get all'
alias kgaa='kubectl get all -A'
alias kgev='kubectl get events --sort-by=".lastTimestamp"'

#=============================================================================
# DESCRIBE OPERATIONS
#=============================================================================
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'
alias kdcm='kubectl describe configmap'
alias kdsec='kubectl describe secret'
alias kdi='kubectl describe ingress'
alias kdpv='kubectl describe pv'
alias kdpvc='kubectl describe pvc'

#=============================================================================
# LOGS
#=============================================================================
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klt='kubectl logs --tail'
alias klp='kubectl logs --previous'

#=============================================================================
# EXEC / RUN
#=============================================================================
alias kex='kubectl exec -it'
alias krun='kubectl run'
alias kcp='kubectl cp'

#=============================================================================
# DELETE
#=============================================================================
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdelf='kubectl delete -f'

#=============================================================================
# APPLY / CREATE
#=============================================================================
alias ka='kubectl apply -f'
alias kaf='kubectl apply -f'
alias kc='kubectl create'
alias kcf='kubectl create -f'

#=============================================================================
# CONTEXT AND NAMESPACE
#=============================================================================
alias kctx='kubectl config get-contexts'
alias kctxu='kubectl config use-context'
alias kctxc='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'
alias knsget='kubectl config view --minify --output "jsonpath={..namespace}"'

#=============================================================================
# CLUSTER INFO
#=============================================================================
alias kci='kubectl cluster-info'
alias kv='kubectl version'
alias kapi='kubectl api-resources'
alias kapiv='kubectl api-versions'

#=============================================================================
# SCALE / ROLLOUT
#=============================================================================
alias ksc='kubectl scale'
alias kro='kubectl rollout'
alias kros='kubectl rollout status'
alias kroh='kubectl rollout history'
alias kror='kubectl rollout restart'
alias krou='kubectl rollout undo'

#=============================================================================
# TOP / RESOURCE USAGE
#=============================================================================
alias ktop='kubectl top'
alias ktopn='kubectl top nodes'
alias ktopp='kubectl top pods'
alias ktoppa='kubectl top pods -A'

#=============================================================================
# PORT FORWARD
#=============================================================================
alias kpf='kubectl port-forward'

#=============================================================================
# FUNCTIONS
#=============================================================================

# Interactive pod selector
function kpf() {
    local pod
    pod=$(kubectl get pods --no-headers | \
        fzf --header '╭─ Select Pod ─╮' \
            --preview 'kubectl describe pod $(echo {} | awk "{print \$1}")' | \
        awk '{print $1}')
    
    [[ -n "$pod" ]] && echo "$pod"
}

# Interactive pod exec
function kexf() {
    local pod=$(kpf)
    local container="${1:-}"
    
    if [[ -n "$pod" ]]; then
        if [[ -n "$container" ]]; then
            kubectl exec -it "$pod" -c "$container" -- /bin/sh
        else
            kubectl exec -it "$pod" -- /bin/sh
        fi
    fi
}

# Interactive log viewer
function klf() {
    local pod=$(kpf)
    [[ -n "$pod" ]] && kubectl logs -f "$pod"
}

# Interactive context switch
function kctxf() {
    local ctx
    ctx=$(kubectl config get-contexts --no-headers | \
        fzf --header '╭─ Select Context ─╮' | \
        awk '{print $2}')
    
    if [[ -n "$ctx" ]]; then
        kubectl config use-context "$ctx"
        echo "Switched to context: $ctx"
    fi
}

# Interactive namespace switch
function knsf() {
    local ns
    ns=$(kubectl get namespaces --no-headers | \
        fzf --header '╭─ Select Namespace ─╮' | \
        awk '{print $1}')
    
    if [[ -n "$ns" ]]; then
        kubectl config set-context --current --namespace="$ns"
        echo "Switched to namespace: $ns"
    fi
}

# Get shell in pod
function ksh() {
    local pod="${1:-}"
    local shell="${2:-/bin/sh}"
    
    if [[ -z "$pod" ]]; then
        pod=$(kpf)
    fi
    
    [[ -n "$pod" ]] && kubectl exec -it "$pod" -- "$shell"
}

# Watch pods
function kwp() {
    watch -n 2 'kubectl get pods'
}

# Watch pods all namespaces
function kwpa() {
    watch -n 2 'kubectl get pods -A'
}

# Pod resource usage
function kres() {
    kubectl top pods | sort -k3 -h -r
}

# Node resource usage
function knres() {
    kubectl top nodes
}

# Get all resources in namespace
function kall() {
    local ns="${1:-default}"
    kubectl get all -n "$ns"
}

# Delete pod (with confirmation)
function kdelpod() {
    local pod="${1:-}"
    
    if [[ -z "$pod" ]]; then
        pod=$(kpf)
    fi
    
    if [[ -n "$pod" ]]; then
        read -q "?Delete pod '$pod'? [y/N] "
        echo
        [[ $REPLY == "y" ]] && kubectl delete pod "$pod"
    fi
}

# Force delete pod
function kdelpodf() {
    local pod="${1:-}"
    
    if [[ -z "$pod" ]]; then
        pod=$(kpf)
    fi
    
    if [[ -n "$pod" ]]; then
        kubectl delete pod "$pod" --grace-period=0 --force
    fi
}

# Get pod YAML
function kgy() {
    local pod="${1:-}"
    
    if [[ -z "$pod" ]]; then
        pod=$(kpf)
    fi
    
    [[ -n "$pod" ]] && kubectl get pod "$pod" -o yaml | bat -l yaml
}

# Edit resource with fzf
function keditf() {
    local resource="${1:-pod}"
    local name
    
    name=$(kubectl get "$resource" --no-headers | \
        fzf --header "╭─ Select $resource to edit ─╮" | \
        awk '{print $1}')
    
    [[ -n "$name" ]] && kubectl edit "$resource" "$name"
}

# Quick deployment scale
function kscale() {
    local deployment="${1:-}"
    local replicas="${2:-}"
    
    if [[ -z "$deployment" ]]; then
        deployment=$(kubectl get deployments --no-headers | \
            fzf --header '╭─ Select Deployment ─╮' | \
            awk '{print $1}')
    fi
    
    if [[ -z "$replicas" ]]; then
        read "replicas?Replicas: "
    fi
    
    [[ -n "$deployment" && -n "$replicas" ]] && \
        kubectl scale deployment "$deployment" --replicas="$replicas"
}

# Cluster info summary
function kinfo() {
    echo "╭─ Kubernetes Cluster Info ─╮"
    echo "  Context:   $(kubectl config current-context)"
    echo "  Namespace: $(kubectl config view --minify -o jsonpath='{..namespace}')"
    echo "  Nodes:     $(kubectl get nodes --no-headers | wc -l)"
    echo "  Pods:      $(kubectl get pods -A --no-headers | wc -l)"
    echo "╰─────────────────────────────╯"
}

#=============================================================================
# HELM INTEGRATION (if available)
#=============================================================================
if (( $+commands[helm] )); then
    # Lazy-load helm completion
    function helm() {
        unfunction helm 2>/dev/null
        source <(command helm completion zsh)
        command helm "$@"
    }
    
    alias h='helm'
    alias hl='helm list'
    alias hla='helm list -A'
    alias hi='helm install'
    alias hu='helm upgrade'
    alias hui='helm upgrade --install'
    alias hd='helm delete'
    alias hs='helm search'
    alias hsr='helm search repo'
    alias hsh='helm search hub'
    alias hr='helm repo'
    alias hrl='helm repo list'
    alias hru='helm repo update'
    alias hra='helm repo add'
    alias hv='helm version'
    alias hh='helm history'
    alias hrb='helm rollback'
fi

#=============================================================================
# K9S INTEGRATION (if available)
#=============================================================================
if (( $+commands[k9s] )); then
    alias k9='k9s'
fi
