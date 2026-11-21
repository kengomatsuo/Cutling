import re,html,subprocess,sys,os,json
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
def fetch(name,url):
    f=f'{name}.html'
    if not os.path.exists(f) or os.path.getsize(f)<2000:
        subprocess.run(['curl','-sL','-A',UA,url,'-o',f])
    s=open(f,encoding='utf8',errors='ignore').read()
    m=re.search(r'<div id="?\'?main',s)
    body=s
    b=re.search(r'(?s)<main.*?</main>',s)
    if b: body=b.group(0)
    imgs=[]
    for im in re.finditer(r'<img\b[^>]*>',body):
        t=im.group(0)
        src=re.search(r'src=["\']([^"\']+)',t); alt=re.search(r'alt=["\']([^"\']*)',t)
        w=re.search(r'width=["\'](\d+)',t)
        if src: imgs.append((src.group(1),html.unescape(alt.group(1)) if alt else '',w.group(1) if w else ''))
    txt=re.sub(r'(?s)<(script|style|nav)\b.*?</\1>','',body)
    txt=re.sub(r'<img\b[^>]*alt=["\']([^"\']*)["\'][^>]*>',r' [IMG: \1] ',txt)
    txt=re.sub(r'</(p|li|h\d|div|tr)>','\n',txt); txt=html.unescape(re.sub(r'<[^>]+>','',txt))
    txt=re.sub(r'\n\s*\n+','\n',txt)
    open(f'{name}.txt','w').write(url+'\n\n'+txt)
    return len(s),len(txt),imgs
if __name__=='__main__':
    out={}
    for line in open(sys.argv[1]):
        if not line.strip(): continue
        name,url=line.split()
        a,b,imgs=fetch(name,url)
        big=[i for i in imgs if not i[2] or int(i[2])>100]
        out[name]={'url':url,'imgs':imgs}
        print(name,a,b,len(imgs),'imgs', len(big),'big')
    json.dump(out,open(sys.argv[2],'w'),indent=1)
