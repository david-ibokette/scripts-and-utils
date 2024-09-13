val msg = "waltham community block party sat 12-3 @ the park"
val letterToCountMap = mutableMapOf<Char, Int>()
msg
.filterNot { it.isWhitespace() }
.forEach{
    letterToCountMap[it] = letterToCountMap.getOrPut(it, {0}) + 1;
}

val countToLetterListMap = mutableMapOf<Int, MutableList<Char>>()
letterToCountMap.forEach{
    countToLetterListMap.getOrPut(it.value) { mutableListOf<Char>() }.add(it.key)
}

//map.forEach{
//    print("${it.key}=${it.value};")
//}

countToLetterListMap.toSortedMap(reverseOrder()).forEach{
    println("${it.key}=${it.value}")
}
