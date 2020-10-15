# https://github.com/redis/redis-rb/blob/087a11b585978cd3970d22d066b7d8ccd89a40f6/lib/redis.rb
# 中文详解： https://www.cnblogs.com/funyoung/p/10730525.html

------------- 2.1 String ------------- 

#设置字符串类型的Key
set key value
​
#仅当Key不存在时设置字符串类型的Key
setnx key value
​
#设置字符串类型的Key并添加过期时间
setex key second value
​
#获取Key对应的Value
get key
​
#让Key对应的Value值递增1
incr key
​
#让Key对应的Value值递减1
decr key
​
#让Key对应的Value递增指定的数值
incrby key num
​
#让Key对应的Value递减指定的数值
decrby key num
​
#往Key对应的Value中追加字符串
append key str

------------- 2.2 Hash ------------- 

#往Hash中添加一个属性
hset key field value
​
#仅当Key不存在时往Hash中添加一个属性
hsetnx key field value
​
#往Hash中添加多个属性
hmset key field1 value1 field2 value2
​
#获取Hash中指定的一个属性
hget key field
​
#获取Hash中指定的多个属性
hmget key field1 field2
​
#获取Hash中所有的属性
hgetall key
​
#让Hash中指定的属性递增指定的数值(属性值必须是数值类型)
hincrby key field num
​
#判断Hash中指定的属性是否存在
hexists key field
​
#获取Hash中属性的个数
hlen key
​
#获取Hash中所有的属性名
hkeys key
​
#获取Hash中所有的属性值
hvals key
​
#删除Hash中指定的多个属性
hdel key field1 field2

------------- 2.3 List ------------- 

#从链表的左侧添加元素
lpush key value
​
#从链表的右侧添加元素
rpush key value
​
#仅当Key存在时从链表的左侧添加元素
lpushx key value
​
#仅当Key存在时从链表的右侧添加元素
rpushx key value
​
#获取链表中指定索引范围的元素(从链表的左侧开始遍历,包括begin和end的位置,如果end为-1表示倒数第一个元素)
lrange key begin end
​
#从链表的左侧弹出一个元素
lpop key
​
#从链表的右侧弹出一个元素
rpop key
​
#获取链表中元素的个数
llen key
​
#删除链表中指定个数个Value(若count为正数，则从链表的左侧开始删除指定个数个Value，若count为负数，则从链表的右侧开始删除指定个数个Value，若count为0，则删除链表中所有指定的Value)
lrem key count value
​
#设置链表中指定索引的值
lset key index value
​
#从链表的右侧弹出元素并将其放入到其他链表的左侧(一般用在消息队列的备份)
rpoplpush key otherKey

------------- 2.4 Set ------------- 

#往Set中添加元素
sadd key value
​
#删除Set中指定的元素
srem key value
​
#查看Set中的元素
smembers key
​
#判断Set中是否包含某个元素
sismemeber key value
​
#返回Set中元素的个数
scard set
​
#返回两个Set的交集
sinter set1 set2
​
#返回两个Set的并集
sunion set1 set2
​
#返回Set1中Set2没有的元素(补集)
sdiff set1 set2
​
#将Set1和Set2的交集放入到新的Set中
sinterstore destSet set1 set2
​
#将Set1和Set2的并集放入到新的Set中
sunionstore destSet set1 set2
​
#将Set1中Set2没有的元素放入到新的Set中
sdiffstore destSet set1 set2


------------- 2.5 ZSet ------------- 

#往ZSet中添加元素
zadd key score value
​
#获取ZSet中指定Value的分数
zscore key value
​
#返回ZSet中元素的个数
zcard key
​
#获取ZSet中指定索引范围的元素(包括begin和end的位置,end为-1时表示倒数第一个元素)
zrange key begin end
​
#获取ZSet中指定索引范围的元素以及分数,返回的元素按照分数从小到大排序
zrange key begin end withscores
​
#获取ZSet中指定索引范围的元素以及分数,返回的元素按照分数从大到小进行排序
zrevrange key begin end withscores
​
#获取ZSet中指定分数范围的元素(包括begin和end的位置)
zrangebyscore key begin end
​
#获取ZSet中指定分数范围的元素并限制返回的个数
zrangebyscore key begin end limit num
​
#返回ZSet中指定分数范围元素的个数
zcount key begin end
​
#删除ZSet中指定的元素
zrem key value
​
#删除ZSet中指定分数范围的元素(包括begin和end的位置)
zremrangebyscore key begin end
​
#让ZSet中指定元素的分数递增指定的值
zincrby key score value

------------- 2.6 HyperLogLog ------------- 

#往HyperLogLog中添加元素
pfadd key value [value]
​
#统计HyperLogLog中的基数
pfcount key
​
#将多个HyperLogLog合并成一个
pfmerge destkey originKey [originKey...]

------------- 2.7 BitMap ------------- 

#设置bitMap，并指定offset，value取值为0或1
setbit key offset value
​
#获取bitMap中指定offset的value
getbit key offset
​
#返回bitMap中value为1的个数
bitcount key
​
#进行bitMap之间的与、或、非、异或运算，并将运算后的结果放入目标bitmap
bitop and/or/not/xor destKey sourceKey [sourceKey]

------------- 2.8 通用命令 ------------- 

#查看Redis中的Key(支持通配符,*代表任意个字符,?代表任意一个字符)
keys pattern
​
#删除Key
del key
​#redis4.0支持使用unlink来删除大Key，避免使用del命令删除大Key时长时间阻塞，导致Redis短暂无法对外提供服务unlink key
#判断Key是否存在
exists key
​
#对Key进行重命名
rename oldKey newKey
​
#对Key设置过期时间
expire key seconds
​
#查看Key的有效时间(若Key没有设置过期时间则返回-1)
ttl key
​
#查看Key的类型
type key