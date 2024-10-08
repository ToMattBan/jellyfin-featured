#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Getting user preferences
read -p "$(echo -e Input, ${YELLOW}in seconds${NC}, how much time each slide should be shown --\> ) " slide_time
slide_time=$((slide_time * 1000)) # Times 1000 to convert to milisseconds

read -p "$(echo -e How many ${YELLOW}movies${NC} you want to be fetched if no list is found? --\> ) " movies_count
read -p "$(echo -e How many ${YELLOW}series${NC} you want to be fetched if no list is found? --\> ) " series_count


# The files, single lined, that will be created to be used
css='@import url(https://fonts.googleapis.com/css2?family=Noto+Sans&display=swap);.backdrop,.slide{position:absolute}.featured-content,.plot-container{font-family:"Noto Sans",sans-serif;left:0}.plot,body{overflow:hidden}body{margin:0;padding:0}.fade-in{opacity:1!important}.fade-out{opacity:0!important}.slide{opacity:0;transition:opacity 1s ease-in-out;top:0;left:0;width:100%;height:100%}.slide.active{opacity:1;z-index:1}.slide:focus{outline:#fff solid 2px}.backdrop{right:0;width:70%;height:calc(100% - 50px);object-fit:cover;object-position:center 20%;border-radius:5px;z-index:1;loading:lazy}.logo-container{width:35%;height:40%;position:relative;display:flex;justify-content:center;align-items:center}.logo{max-height:80%;max-width:80%;width:auto;z-index:3;loading:lazy}.featured-content{position:absolute;top:0;width:100%;height:50px;background-color:transparent;color:#d3d3d3;font-size:22px;display:none;align-items:center;justify-content:flex-start;z-index:2}.plot-container{position:absolute;bottom:0;color:#fff;width:33%;height:60%;font-size:15px;padding:10px 0 25px 15px;border-radius:5px;z-index:4;box-sizing:border-box;display:flex;align-items:center;justify-content:center;text-align:center}.plot{display:-webkit-box;line-clamp:8;-webkit-line-clamp:8;-webkit-box-orient:vertical}.gradient-overlay{position:absolute;top:0;left:0;width:70%;height:100%;background:linear-gradient(to right,#000 49%,rgba(0,0,0,0) 70%);z-index:2}@media only screen and (max-width:767px){.gradient-overlay{width:100%;height:68%;top:unset;bottom:0;background:linear-gradient(to top,#000 49%,rgba(0,0,0,0) 70%)}.backdrop{width:100%}.logo-container{width:50%;height:35%;justify-content:start;align-items:start;margin:10px}.logo{padding:5px;background:rgba(0,0,0,.5);border-radius:5px}.plot-container{padding:10px;height:35%;width:100%}.plot{line-clamp:4;-webkit-line-clamp:4}}'
js='const shuffleInterval=$slide_time,listFileName=`${window.location.origin}/web/avatars/list.txt`,jsonCredentials=sessionStorage.getItem("json-credentials"),apiKey=sessionStorage.getItem("api-key");let userId=null,token=null;if(jsonCredentials){const e=JSON.parse(jsonCredentials);userId=e.Servers[0].UserId,token=e.Servers[0].AccessToken}const shuffleArray=e=>e.sort((()=>Math.random()-.5)),createSlideElement=(e,t)=>{const o=e.Id,i=e.Overview||"No overview available",s=document.createElement("a");s.className="slide",s.href=`${window.location.origin}/web/#/details?id=${o}`,s.target="_top",s.rel="noreferrer",s.tabIndex=0;const n=document.createElement("img");n.className="backdrop",n.src=`${window.location.origin}/Items/${o}/Images/Backdrop/0`,n.alt="Backdrop",n.loading="lazy";const a=document.createElement("img");a.className="logo",a.src=`${window.location.origin}/Items/${o}/Images/Logo`,a.alt="Logo",a.loading="lazy";const r=document.createElement("div");r.className="logo-container",r.appendChild(a);const l=document.createElement("div");l.className="featured-content",l.textContent=t;const c=document.createElement("span");c.className="plot",c.textContent=i;const d=document.createElement("div");d.className="plot-container",d.appendChild(c);const m=document.createElement("div");return m.className="gradient-overlay",s.append(m,n,r,l,d),s},createSlideForItem=async(e,t)=>{const o=document.getElementById("slides-container"),i=e.Id,s=`${window.location.origin}/Items/${i}/Images/Backdrop/0`,n=`${window.location.origin}/Items/${i}/Images/Logo`,[a,r]=await Promise.all([fetch(s,{method:"HEAD"}).then((e=>e.ok)),fetch(n,{method:"HEAD"}).then((e=>e.ok))]);if(a&&r){const s=createSlideElement(e,t);o.appendChild(s),console.log(`Added slide for item ${i}`),1===o.children.length&&showSlide(0)}else console.warn(`Skipping item ${i}: Missing backdrop or logo.`)},fetchItemDetails=async e=>{const t=await fetch(`${window.location.origin}/Users/${userId}/Items/${e}`,{headers:{Authorization:`MediaBrowser Client="Jellyfin Web", Device="YourDeviceName", DeviceId="YourDeviceId", Version="YourClientVersion", Token="${token}"`}}),o=await t.json();return console.log("Item Title:",o.Name),console.log("Item Overview:",o.Overview),o},fetchItemIdsFromList=async()=>{try{const e=await fetch(listFileName);if(!e.ok)throw new Error("Failed to fetch list.txt");return(await e.text()).split("\n").map((e=>e.trim())).filter((e=>e))}catch(e){return console.error("Error fetching list.txt:",e),[]}},fetchItemsFromServer=async()=>{try{const e=await fetch(`${window.location.origin}/Users/${userId}/Items?IncludeItemTypes=Movie,Series&Recursive=true&hasOverview=true&imageTypes=Logo,Backdrop&isPlayed=False&Limit=1500`,{headers:{Authorization:`MediaBrowser Client="Jellyfin Web", Device="YourDeviceName", DeviceId="YourDeviceId", Version="YourClientVersion", Token="${token}"`}}),t=(await e.json()).Items,o=t.filter((e=>"Movie"===e.Type)),i=t.filter((e=>"Series"===e.Type)),s=shuffleArray(o),n=shuffleArray(i),a=s.slice(0,$movies_count),r=n.slice(0,$series_count),l=[],c=Math.max(a.length,r.length);for(let e=0;e<c;e++)e<a.length&&l.push(a[e]),e<r.length&&l.push(r[e]);return l}catch(e){return console.error("Error fetching items:",e),[]}},createSlidesForItems=async e=>{await Promise.all(e.map((e=>createSlideForItem(e,"Movie"===e.Type?"Movie":"TV Show"))))},showSlide=e=>{document.querySelectorAll(".slide").forEach(((t,o)=>{o===e?(t.style.display="block",t.offsetHeight,t.style.opacity="1",t.classList.add("active")):(t.style.opacity="0",t.classList.remove("active"),setTimeout((()=>{t.style.display="none"}),500))}))},initializeSlideshow=()=>{const e=document.querySelectorAll(".slide"),t=document.getElementById("slides-container");let o=0,i=null,s=!1;const n=t=>{o=(t+e.length)%e.length,showSlide(o)},a=()=>{i&&(window.location.href=i.href)};e.length>0&&(showSlide(o),t.style.display="block",setTimeout((()=>{setInterval((()=>{n(o+1)}),1e4)}),1e4)),e.forEach((e=>{e.addEventListener("focus",(()=>{i=e,t.classList.remove("disable-interaction")}),!0),e.addEventListener("blur",(()=>{i===e&&(i=null)}),!0)})),document.addEventListener("keydown",(e=>{if(s)switch(e.keyCode){case 37:n(o-1);break;case 39:n(o+1);break;case 13:a()}})),document.addEventListener("click",(e=>{e.target.closest(".slide")&&a()})),document.addEventListener("focusin",(e=>{e.target.closest("#slides-container")&&(s=!0,t.classList.remove("disable-interaction"))})),document.addEventListener("focusout",(e=>{e.target.closest("#slides-container")||(s=!1,t.classList.add("disable-interaction"))}))},initializeSlides=async()=>{const e=await fetchItemIdsFromList();let t;if(e.length>0){const o=e.map((e=>fetchItemDetails(e)));t=await Promise.all(o)}else{const e=(await fetchItemsFromServer()).map((e=>fetchItemDetails(e.Id)));t=await Promise.all(e)}await createSlidesForItems(t),initializeSlideshow()};jsonCredentials&&apiKey?initializeSlides():console.error("No credentials or API key found.");'

# Replacing parts of the file with variables
js="${js//\$slide_time/$slide_time}"
js="${js//\$movies_count/$movies_count}"
js="${js//\$series_count/$series_count}"

# Use printf to handle create the files
printf '%s\n' "$css" > slideshowStyle.css
printf '%s\n' "$js" > slideshowScript.js


# "Installing" it, modifying jellyfin files
nedded_functions='function saveCredentialsToSessionStorage(e){try{sessionStorage.setItem("json-credentials",JSON.stringify(e)),console.log("Credentials saved to sessionStorage.")}catch(e){console.error("Error saving credentials:",e)}}function saveApiKey(e){try{sessionStorage.setItem("api-key",e),console.log("API key saved to sessionStorage.")}catch(e){console.error("Error saving API key:",e)}}!function(){var e=console.log;console.log=function(r){if(e.apply(console,arguments),"string"==typeof r&&r.startsWith("Stored JSON credentials:"))try{var s=r.substring(25);saveCredentialsToSessionStorage(JSON.parse(s))}catch(e){console.error("Error parsing credentials:",e)}if("string"==typeof r&&r.startsWith("opening web socket with url:"))try{var o=r.split("url:")[1].trim(),t=new URL(o).searchParams.get("api_key");t&&saveApiKey(t)}catch(e){console.error("Error extracting API key:",e)}}}();'
printf '%s\n' "$nedded_functions" > init_script.js

find='</body></html>'
replace_with='<script src="/web/avatars/init_script.js"></script></body></html>'

file="../index.html"
sed -i "s|${find}|${replace_with}|g" "$file"

parent_dir="../"
pattern="home-html.*.chunk.js"
file=$(find "$parent_dir" -maxdepth 1 -name "$pattern" 2>/dev/null)

find='"movie,series,book">'
replace_with='"movie,series,book"><link rel="stylesheet" href="/web/avatars/slideshowStyle.css"><div id="slides-container"></div><script async src="/web/avatars/slideshowScript.js"></script>'
sed -i "s|${find}|${replace_with}|g" "$file"