val msg = "community block party sunday 2-5 @ the park"
val map = mutableMapOf<Char, Int>()
msg
    .filterNot { it.isWhitespace() }
    .forEach{
        map[it] = map.getOrPut(it, {0}) + 1;
}

val map2 = mutableMapOf<Int, MutableList<Char>>()
map.forEach{
    map2.getOrPut(it.value) { mutableListOf<Char>() }.add(it.key)
}

//map.forEach{
//    print("${it.key}=${it.value};")
//}

map2.toSortedMap(reverseOrder()).forEach{
    println("${it.key}=${it.value}")
}
