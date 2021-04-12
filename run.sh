./rinstall.sh
json='{"workbench.colorTheme": "Visual Studio Dark", "code-runner.runInTerminal": true, "code-runner.saveFileBeforeRun": true}'
echo $json > /home/coder/.local/share/code-server/User/settings.json
if [ -n "${BASE_CONF}" ] && [ -n "${CLOUD_NAME}" ] ; then
    pgrep rclone
    if [ $? -eq 0 ]; then
        echo "already mounred skipping"
    else 
        echo $BASE_CONF | base64 -d > .rclone.conf
        rclone serve sftp  $CLOUD_NAME:$SUB_DIR --no-auth --vfs-cache-mode full&
    fi
        
else 
    echo "CLOUD NOT MOUNTED" > /home/coder/CLOUD_NOT_MOUNTED
fi
rm *
