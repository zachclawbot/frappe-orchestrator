#!/bin/bash
# kill-redis.sh - Kills all Redis instances so bench can manage them
pkill -f redis-server 2>/dev/null || true
sleep 2
echo "Redis port 13000: $(redis-cli -p 13000 ping 2>/dev/null || echo FREE)"
echo "Redis port 11000: $(redis-cli -p 11000 ping 2>/dev/null || echo FREE)"
echo "Done"
