xquery version "3.1";

module namespace app="http://exist-db.org/apps/shaoyong/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/shaoyong/config" at "config.xqm";
import module namespace web="http://exist-db.org/apps/shaoyong/web" at "web.xqm";
import module namespace functx="http://www.functx.com" at "functx.xql";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function app:getParameters($node as node(), $model as map(*), $titleId as xs:string?, $path as xs:string?, $mode as xs:integer?, $coll as xs:string?){
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
        map{"titleNode":$titleNode, "bookTitle": $bookTitle, "currentDiv":$currentDiv, "author":$bookAuthors, "titleId":$titleId, "path":$path, "mode":$mode}
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
                $web:homepage
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
declare function app:right($node as node(), $model as map(*)){
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
    return $result
};