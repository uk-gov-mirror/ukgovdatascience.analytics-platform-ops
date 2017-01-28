node {
    stage ('Update') {

        def pod_name = sh(
            script: "kubectl get pods --selector=app=r-studio-example -o jsonpath='{.items[*].metadata.name}'",
            returnStdout: true
        ).trim()

        def group = 'rstudio'
        def cmds = []
        for (user in users.split("\\r?\\n")){
            user = user.toLowerCase().replaceAll(/.gov.uk$/, '').replaceAll(/[^a-z0-9_]/, '-')
            if (user.length() >=32) {
                user = user[0..31]
            }

            cmds << """
                if ! getent passwd ${user} > /dev/null 2>&1; then \\
                    sudo useradd -g ${group} -m -d /r-home/${user} -s /dev/null ${user}; \\
                fi \\
            """
        }

        cmds = cmds.join('&&')

        sh """
            kubectl exec ${pod_name} -c r-studio-server  -- /bin/sh -c "${cmds}"
        """
    }
}
