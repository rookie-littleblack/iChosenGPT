
# Check Environment Variables!
if [ -z "${CM_ROOT}" ]; then
    echo "Environment Variable 'CM_ROOT' Should Be Set First!"
    exit 1
fi
if [ -z "${CM_ROOT1}" ]; then
    echo "Environment Variable 'CM_ROOT1' Should Be Set First!"
    exit 1
fi

echo "test2 CM_ROOT: "$CM_ROOT
echo "test2 CM_ROOT1: "$CM_ROOT1