xquery version "3.1";
module namespace web="http://exist-db.org/apps/shaoyong/web";

declare variable $web:homepage :=
    <div>
        <div class="page-header">
            <h1>邵雍研究網</h1>
        </div>
        <div class="alert alert-success">
            <p>歡迎參觀本網站。本網站的設立宗旨，在於探究數位人文的方法對於邵雍文化思想遺產的研究。</p>
            <p>請依照右邊的說明進行操作，或直接點選選單上的功能探勘本站的資源。</p>
        </div>
    </div>;
declare variable $web:homepageRight :=
        <p>請點選功能表中的選項，或是利用上列的檢索表單進行本站的檢索。</p>;
        
declare function web:webpage($leftnode as node(), $rightnode as node(), $titleID as xs:string?){
<div class="row">
        <div class="col-md-9">
           {$leftnode}
        <div class="row">
            <div class="col-md-6">
                <p>本網站網頁利用<a href="http://twitter.github.com/bootstrap/">Bootstrap</a>
                    CSS 資源庫來呈現。</p>
                <p><img width="120px" height="40px" src="http://exist-db.org/exist/apps/homepage/resources/img/existdb.gif" alt="eXist-db"/><a href="http://exist-db.org/exist/apps/homepage/index.html">eXistdb</a> is Open Source Software licensed under the LGPL</p>
                <!--<p>您可以下載本網站所有檔案壓縮檔<a href="https://drive.google.com/open?id=0B_FdoTA4ll-wNmo5Uk4wSWJzdDg">shaoyong.xar</a>，並裝到自己設置的eXistdb平台使用。點選連結後，請按左上角下載鍵。目前更新版本2017-07-09。</p>-->
            </div>
            <div class="col-md-6">
                <p>若對本網站有什麼建議指教，歡迎連絡：<a href="mailto:dh@ptc.cl.nthu.edu.tw">祝平次</a>。</p>
                <p><img src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" alt="Creative Commons License"/>(c) Kanseki Repository. All content created by us is licensed under a CC BY SA license.</p>
                <p>{current-dateTime()}</p>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        {web:search-form($titleID)}
        {$rightnode}
    </div>
</div>};
declare function web:search-form($titleId as xs:string?){
    <form method="get" action="index.html">
        <h3>請輸入檢索詞：</h3>
        <input name="query" class="col-md-12"/>
        {if ($titleId) then
            <span><input type="hidden" name="titleId"/> {attribute value {$titleId}}</span>
        else ()}
        <input class="btn btn-primary btn-md" type="submit" value="進行檢索"/>　<a href="query.html" style="float:right;" class="btn btn-success btn-md">高級檢索</a>
    </form>
        };
declare variable $web:log :=
    <div>
        <h2>功能日記</h2>
        <ul class="alert alert-success">
            <li>2017-07-09：上傳Kanripo經部資料，重新編寫分層瀏覽，以將檔案結構，調整為以卷為單位。</li>
        </ul>
    </div>;
declare variable $web:roadmap :=
    <div>
        <h2>擬設功能</h2>
        <ol  class="alert alert-success">
            <li>依計畫需求，陸續進行檔案的格式化。</li>
            <li>整合網站書單和四庫書單。</li>
            <li>文字比對，以便自動校勘，以及利用已標點文件處理未標點文件。</li>
        </ol>
    </div>;