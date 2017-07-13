xquery version "3.1";

module namespace app="http://exist-db.org/apps/shaoyong/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/shaoyong/config" at "config.xqm";
import module namespace web="http://exist-db.org/apps/shaoyong/web" at "web.xqm";
import module namespace functx="http://www.functx.com" at "../../shared-resources/content/functx.xql";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare function app:getParameters($node as node(), $model as map(*), $coll as xs:string?, $titleId as xs:string?, $path as xs:string?, $mode as xs:integer?){
    let $titleNode :=
        if ($titleId) then
            if ($coll) then
                collection($config:data-root||"/"||$coll)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/@xml:id eq $titleId]
            else
                collection($config:data-root)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/@xml:id eq $titleId]
        else ()
    let $bookTitle :=
        if ($titleNode) then
            $titleNode/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
        else ()
    let $bookAuthors :=
        if ($titleNode) then
            $titleNode/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author
        else ()
    let $currentDiv :=
        if ($path) then app:divPath($titleNode/tei:text/tei:body, $path)
        else
            if ($titleNode) then $titleNode/tei:text/tei:body
            else ()
    return
        map{"titleNode":$titleNode, "bookTitle": $bookTitle, "currentDiv":$currentDiv, "author":$bookAuthors, "titleId":$titleId, "coll":$coll, "path":$path, "mode":$mode}
};
declare function app:makelink($path as xs:string, $model as map(*), $count as xs:integer)as xs:string{
    let $pathList := tokenize($path, "-")
    let $pathRemoveLast := string-join(remove($pathList, count($pathList)), "-")
    return
        if ($count eq count($pathList)) then
            "index.html?mode=2&amp;titleId="||$model("titleId")||"&amp;path="||$path
        else app:makelink($pathRemoveLast, $model, $count)
};
declare function app:left($node as node(), $model as map(*)){
    let $result:=
            if ($model("mode") = 1) then app:bookTitles()
            else if ($model("mode") = 2) then 
                <div>
                    {app:firstDiv($model)}
                </div>
            else
                config:homepage()

    return $result
};
declare function app:divPath($node as node(), $path as xs:string?)as node(){
if ($path) then
    if (count(tokenize($path, "-")) gt 1) then
        app:divPath($node/tei:div[position()=number(substring-before($path, "-"))], substring-after($path, "-"))
    else
        $node/tei:div[position()=number($path)]
else
    $node
}; 
declare function app:contentList($body as node()){
    <ul>{for $div at $count in $body/tei:div
        return        
        <li>{$div/tei:head/text()}
            {
                app:contentList($div)
            }
        </li>
        }
    </ul>
};
declare function app:divHeader($model as map(*)){
let $pathList := tokenize($model("path"), "-")
let $pathList2 :=
    for $p in 1 to count($pathList)
    return
        <path>{
        let $pathlink :=
            for $q in 1 to $p
            return
                if ($q eq $p) then $pathList[$q]
                else $pathList[$q]||"-"
        return string-join($pathlink)
         }</path>
let $node := $model("currentDiv")
let $linkFirstPart := "index.html?mode=2&amp;titleId="||$model("titleId")||"&amp;path="
let $linkList :=
    for $link at $count in $pathList2
    return $linkFirstPart||$pathList2[$count]
return
    for $div at $count in $node/ancestor-or-self::tei:div
    return
            <a>{attribute href {$linkList[$count]}}<span>{attribute style {"color:rgb(50,"||string(200-($count - 1)*20)||","||string(200-($count - 1)*30)||")"}}{$div/tei:head/text()}</span>/</a>
};
declare function app:firstDiv($model as map(*)) as node(){
let $titleUrl := "index.html?mode=2&amp;titleId="||$model("titleId")
let $divs := $model("currentDiv")
return
    <div>
    <h2><a>{attribute href {$titleUrl}}{$model("bookTitle")}</a>：{app:divHeader($model)}</h2>
    <div class="alert alert-success"> 
    {if ($divs/tei:p) then $divs/tei:p
    else ()}
    {if ($divs/tei:div) then
    <ul>{
        for $div at $count in $divs/tei:div
        return        
        <li>{
            let $urllink :=
                if ($model("path")) then "index.html?mode=2&amp;titleId="||$model("titleId")||"&amp;path="||$model("path")||"-"||$count
                else "index.html?mode=2&amp;titleId="||$model("titleId")||"&amp;path="||$count
            return
                <a> {attribute href {$urllink}} 
                {$div/tei:head/text()}</a>}
        </li>
        }
    </ul>
    else ()
    }</div>{$model("currentDiv")/tei:byline[last()]}
    </div>
};
declare function app:firstDivHead($divs as node(), $model as map(*)) as node(){
let $pathList := tokenize($model("path"), "-")
return
        <div>
        <h2>你也可以從下面點選上一層目錄：</h2>
        <ul>{
            for $div at $count in $divs/../tei:div
            return        
            <li>{
                let $urllink :=
                    if (count($pathList) gt 2) then "index.html?mode=2&amp;titleId="||$model("titleId")||"&amp;path="||string-join(remove($pathList, count($pathList)), "-")||"-"||$count
                    else "index.html?mode=2&amp;titleId="||$model("titleId")||"&amp;path="||$count
                return
                    <a> {attribute href {$urllink}} 
                    {$div/tei:head/text()}</a>}
            </li>
            }
            
        </ul>
        </div>    
};
declare function app:bookTitles(){
    let $data:=collection($config:data-root)
    let $books:=$data//tei:TEI
    return
    <ol>
        {for $book in $books order by $book/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title
        return
        <li>{
        let $titleUrl:="index.html?mode=2&amp;titleId="||data($book/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/@xml:id)
        return
        <div>
        <a>{attribute href {$titleUrl}} {data($book/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)}</a>：{
            for $author in $book/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author
            return
                <span>{data($author/tei:persName)}<font color="red">{$author/text()}</font>　</span>}</div>
        }
        </li>
        }
    </ol>
};
declare function app:page($node as node(), $model as map(*), $mode as xs:string?, $path as xs:string?, $titleId as xs:string?, $file as xs:string?){
let $book := (:取得文本資訊:)
    if ($titleId) then doc($config:data-root||"/list.xml")//tei:bibl[data(@n)=$titleId]
    else ()
let $bookTitle := (:文本名稱:)
    if ($book) then data($book/tei:title)
    else ()
let $bookAuthors := (:文本作者:)
    if ($book) then data($book/tei:author)
    else ()
let $titleNode := 
    if ($titleId) then collection($config:data-root||"/kr1/"||$titleId)/tei:TEI
    else ()
let $fileNode := 
    if ($file) then doc($config:data-root||"/kr1/"||$titleId||"/"||$file)/tei:TEI
    else ()
let $currentDiv :=
    if ($path) then app:divPath($fileNode/tei:text/tei:body, $path)
    else if ($fileNode) then  $fileNode/tei:text/tei:body
    else if ($titleNode) then $titleNode/tei:text/tei:body
    else ()
let $leftnode := (:左欄資料:)
    if ($mode eq "54") then $web:roadmap
    else if($mode eq "53") then $web:log
    else if($mode eq "1") then app:bookTitles() (:操作模式1，啟動app:bookTitle功能:)
    else if ($mode eq "2") then app:firstDiv($titleId, $currentDiv, $bookTitle, $file, $path) (:操作模式2，啟動app:firstDiv功能:)
    else $web:homepage
let $rightnode := (:右欄資料:)
    if ($mode eq "54") then <p><br/>左欄是本網站擬設功能，歡迎向本站連絡人提出你想要看到的功能。如果情況允許，我們也會將之納入未來的設計功能當中。</p>
    else if ($mode eq "53") then <p><br/>左欄是目前本網站已完成功能的總表。</p>
    else if ($mode eq "1") then <h4>請點選左邊的書目進行瀏覽</h4>
    else if ($mode eq "2") then 
        if ($path) then app:divHeadOnTheRight($currentDiv, $path, $titleId, $file, $bookTitle)
        else <h4>請點選左邊的項目，以進入下一層目錄。</h4>
    else <p><br/>請點選功能表中的選項，或是利用上列的檢索表單進行本站的檢索。</p>
return
web:webpage($leftnode, $rightnode, $titleId)
};

declare function app:right($node as node(), $model as map(*)){
    let $form :=
       <div>
        <h2>請輸入檢索詞：</h2>
        <form method="get" action="query.html">
            <input name="query"/>
            <input type="hidden" name="titleId"/> {attribute value {$model("titleId")}}
            <input type="submit" value="進行檢索"/><a href="query.html" class="btn btn-default">高級檢索</a>
        </form></div>
    let $result:=
            if ($model("mode")) then 
                if ($model("mode") eq 1) then <h2>請點選左邊的書目進行瀏覽</h2>
                else if ($model("mode") eq 2) then
                    if ($model("path")) then app:firstDivHead($model("currentDiv"), $model)
                    else <h2>請點選左邊的項目，以進入下一層目錄</h2>
                else()
            else
                <div>
                    <p>請選擇功能列中的「示範」以進行功能示範。</p>
                </div>
    return <div>{$form} {$result}</div>
};