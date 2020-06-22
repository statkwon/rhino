# Visualization 담당 : 서경덕, 정권상

Our goal is to make a interactive plot dashboard using shinydashboard in R.

-Reference
1) interactive maps 관련 자료
leaflet + shiny

https://medium.com/@joyplumeri/how-to-make-interactive-maps-in-r-shiny-brief-tutorial-c2e1ef0447da

https://hansenjohnson.org/post/interactive-maps-in-r/

https://geocompr.robinlovelace.net/adv-map.html

https://kuduz.tistory.com/1196

https://m.blog.naver.com/PostView.nhn?blogId=hsj2864&logNo=220909725602&targetKeyword=&targetRecommendationCode=1 - 한글자료

http://blog.naver.com/PostView.nhn?blogId=hsj2864&logNo=221004882027 - 레이아웃조정

Interact with your data and create interactive plots - Shiny app의 Basic structure 설명

https://rstudio.github.io/shinydashboard/structure.html - layout 설정에 대한 코드(infobox등 여러가지 box를 넣는 법}

https://stackoverflow.com/questions/50245925/tabitem-cannot-show-the-content-when-more-functions-in-menuitem-using-shiny-and - body의 menuitem menu별로 input type 조정하는법

https://github.com/rstudio/shinydashboard/issues/25 - select input을 tab에 넣었을 때 뜨는 에러 해결(시도결과 에러 해결 X)

https://stackoverflow.com/questions/50245925/tabitem-cannot-show-the-content-when-more-functions-in-menuitem-using-shiny-and - several input types을 tab에 넣어을 때 근래 발생하는 문제 해결법 (찐문제해결)

https://stackoverflow.com/questions/21465411/r-shiny-passing-reactive-to-selectinput-choices
(Tab 1개에 selectinput을 여러개 넣어서 reactive input을 받는 법)

https://github.com/rstudio/shiny/issues/650 (플랏 사이즈 조정 -> body에 조정하고 server에도 조정해야함! 총 두번)

2) Shiny dashboard 호스팅 방법

https://wikidocs.net/66610 -> ui, server R파일 따로 만들어서 시도하였으나 에러발생

http://blog.naver.com/PostView.nhn?blogId=hsj2864&logNo=220915578619&redirect=Dlog&widgetTypeCall=true

https://m.blog.naver.com/PostView.nhn?blogId=hsj2864&logNo=220892395419&proxyReferer=https:%2F%2Fwww.google.com%2F


2020.06.01 Visualization 팀 회의(대쉬보드 레이아웃 구조)
- Tab1) Data table1 -> 소수점 정리하기
-> Feature table

- Tab2) Feature별 barplot구하기 

- Tab3) Interactive map1 (색깔의 진하기로 값 표시) (권상이형)
-> Sidebar에 feature 선택

- Tab4) Data table2
-> 수소차대수 table
-> Check box(단일선택)로 updating

- Tab5) Interactive map2
-> 수소 충전소 입지 선정
-> Check box(단일선택)로 updating
 
필요사항 : 
Tab1) 소수점 정리
Tab2) 레이아웃(특히 사이즈)조정
Tab3) 레이아웃 조정
-> animation

2020.06.12~14 Visualization 팀 주요 변동 사항
- Tab5) 수소 충전소 입지 선정 구현 완료.(구, 동 2가지의 drop-down menu를 이용하여 업데이트)
- Tab4)와 Tab5) 통합 및 테이블과 지도를 박스에 넣어서 레이아웃을 새롭게 배치.

------------------------------------------------------------------------------
D.A.S.H. B.O.A.R.D. 완.성.
