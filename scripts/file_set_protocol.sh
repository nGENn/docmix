
TARGET_CONTAINER=$1

EXISTING_ENTRY=$(docker exec $TARGET_CONTAINER sh -c "grep -P 'overwriteprotocol' /var/www/html/config/config.php")

if [ -z "$EXISTING_ENTRY" ]; then
    echo "Added overwriteprotocol to $TARGET_FILE."
else
    FORMATTED_ENTRY="  '\\''overwriteprotocol'\\'' => '\\''https'\\'',"
    docker exec -i $TARGET_CONTAINER sh -c "sed -i '\$e cat <<EOF\\n$FORMATTED_ENTRY\\nEOF' $TARGET_FILE"
    echo "Added overwriteprotocol to $TARGET_FILE."
fi