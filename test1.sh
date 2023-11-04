
sh test2.sh

subscript_exit_status=$?

if [ $subscript_exit_status -ne 0 ]; then
    echo "子脚本执行失败，退出状态为 $subscript_exit_status"
    exit $subscript_exit_status  # 可选择是否将子脚本的退出状态传递给父脚本
else
    echo "子脚本执行成功"
fi
