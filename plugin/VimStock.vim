

command! -nargs=* Vallstock exec('py TotalStockInfo().GetStock(<f-args>)')

command! -nargs=* Vggzjl exec('py FundsInfo().get_ggzjl(<f-args>)')
command! -nargs=* Vgnzjl exec('py FundsInfo().get_gnzjl(<f-args>)')
command! -nargs=* Vhyzjl exec('py FundsInfo().get_hyzjl(<f-args>)')

command! -nargs=0 Vrun exec('py MiniStock().autorun()')
command! -nargs=0 Vr exec('py MiniStock().refresh_all()')
command! -nargs=0 Vn exec('py MiniStock().Next_page()')
command! -nargs=0 Vp exec('py MiniStock().pre_page()')


command! -nargs=0 Vzs exec('py CMD_Package().get_zs()')
command! -nargs=0 Vzsd exec('py CMD_Package().get_zsd()')

command! -nargs=0 Vzdf exec('py CMD_Package().get_zdf()')
command! -nargs=0 Vzdfd exec('py CMD_Package().get_zdfd()')

command! -nargs=0 Vhs exec('py CMD_Package().get_hs()')
command! -nargs=0 Vhsd exec('py CMD_Package().get_hsd()')

command! -nargs=0 Vdde exec('py CMD_Package().get_dde()')
command! -nargs=0 Vdded exec('py CMD_Package().get_dded()')

command! -nargs=0 Vgn exec('py CMD_Package().get_gn()')
command! -nargs=0 Vgnd exec('py CMD_Package().get_gnd()')

command! -nargs=0 Vhy exec('py CMD_Package().get_hy()')
command! -nargs=0 Vhyd exec('py CMD_Package().get_hyd()')

command! -nargs=* Vbk exec('py FundsInfo().get_bk(<f-args>)')
command! -nargs=0 Vgo exec('py FundsInfo().get_bk_quick()')

command! -nargs=0 Venter exec('py MiniStock().enter()')

command! -nargs=* Vstock exec('py MyStock().getStock(<f-args>)')
command! -nargs=0 Vmystock exec('py MyStock().getMyStock()')
command! -nargs=* Vadd exec('py MyStock().addStock(<f-args>)')
command! -nargs=* Vdel exec('py MyStock().delStock(<f-args>)')

python << EOF
#coding=utf-8


import sys
reload(sys)
sys.setdefaultencoding("utf-8")

import json
import requests
#from bs4 import BeautifulSoup
#from lxml import etree
import pandas as pd
#from tabulate import tabulate
import time
import vim
import re
import os
#import html5lib
#pd.set_option('display.width',200)
#pd.set_option('display.height',1000)
#pd.set_option('display.unicode.east_asian_width', True)
#pd.set_option('display.unicode.ambiguous_as_wide', True)
#pd.set_option('display.colheader_justify','right')
pd.set_option('display.expand_frame_repr', False)
#pd.set_option('display.notebook_repr_html',True)
#pd.set_option('display.encoding','utf-8')
#pd.set_option('display.max_colwidth')

mystockfile = os.path.expandvars('$HOME')+'/.VimStock.mystock'

################################################################################################################
#
#        
#                               个股信息，自选股信息
#
#
################################################################################################################
class MyStock():

    dictName = {'name':'name','now':'10','zdf':'199112','hs':'1968584','kp':'7','zg':'8','zd':'9','zs':'6','zf':'526792','syl':'2034120','sz':'3541450'}

    def getStock(self,code):
        url =  'http://d.10jqka.com.cn/multimarketreal/17,33/'+code+'/1968584_13_19_3541450_526792_6_7_8_9_10_2034120_199112_264648'
        r = requests.get(url)

        self.__parse_stock_text__(r.text)

    def getMyStock(self):
        file_object = open(mystockfile)
        stock_str = ''
        for stock in file_object:
            stock = stock.strip('\n')
            stock_str = stock_str + stock + '_'

        stock_str = stock_str[0:len(stock_str)-1]
        self.getStock(stock_str)
        file_object.close()

        vim.current.buffer.append('')
        vim.current.buffer.append('Vmystock')

    def addStock(self,code):

        file_object = open(mystockfile)
        text  = ''
        for stock in file_object:
            stock = stock.strip('\n')
            text = text + stock + '\n'

        text = text + code + '\n'
        file_object.close()


        output = open(mystockfile, 'w')
        output.write(text)
        output.flush()
        output.close()

    def delStock(self,code):

        file_object = open(mystockfile)
        text  = ''
        for stock in file_object:
            stock = stock.strip('\n')
            if stock != code:
                text = text + stock + '\n'

        file_object.close()


        output = open(mystockfile, 'w')
        output.write(text)
        output.flush()
        output.close()




    def __parse_stock_text__(self,text):
    
        texttemp = text[16:len(text)-1]
        js = json.loads(texttemp)

        del vim.current.buffer[:]
        vim.current.buffer.append('代码        名称     现价  涨跌幅(%) 换手(%)   开盘价  最高价  最低价  昨收价   振幅(%)    市盈率      市值 ')
        vim.current.buffer.append('')

        for key in js.keys():
            dataTmp = js[key]
            for code in dataTmp.keys():
                name = dataTmp[code][self.dictName['name']]
                xj = dataTmp[code][self.dictName['now']]
                zdf = dataTmp[code][self.dictName['zdf']]
                hs = dataTmp[code][self.dictName['hs']]
                kp = dataTmp[code][self.dictName['kp']]
                zg = dataTmp[code][self.dictName['zg']]
                zd = dataTmp[code][self.dictName['zd']]
                zs = dataTmp[code][self.dictName['zs']]
                zf = dataTmp[code][self.dictName['zf']]
                syl = dataTmp[code][self.dictName['syl']]
                sz = dataTmp[code][self.dictName['sz']]

                vim.current.buffer.append('%+6s  %+6s  %+6s  %+6s  %+8s  %+6s  %+6s  %+6s  %+6s  %+8s  %+10s  %+12s'%(code,name,xj,zdf,hs,kp,zg,zd,zs,zf,syl,sz))
                

################################################################################################################
#
#        
#                               所有股票信息
#
#
################################################################################################################
class TotalStockInfo():

    url_base = 'http://q.10jqka.com.cn/index/index/board/all/field'

    url_sortkey_zdf = 'zdf'
    url_sortkey_zs = 'zs'
    url_sortkey_xj = 'xj'
    url_sortkey_hs = 'hs'
    url_sortkey_lb = 'lb'
    url_sortkey_zf = 'zf'
    url_sortkey_syl = 'syl'
    url_sortkey_ltsz = 'ltsz'
    url_sortkey_ltg = 'ltg'
    url_sortkey_cje = 'cje'
    url_sortkey_zd = 'zd'

    #url_asc_desc = 'desc'
    #url_asc_asc = 'asc'
    url_page = '1'


    def get_url(self,sortkey,asc_flag,page):
        #url1 = 'http://q.10jqka.com.cn/index/index/board/all/field/zdf/order/desc/page/1/ajax/1/'
        asc_tmp = 'desc'
        if asc_flag is '0':
            asc_tmp = 'asc'

        return 'http://q.10jqka.com.cn/index/index/board/all/field/'+sortkey+'/order/'+asc_tmp+'/page/'+page+'/ajax/1/'


    def GetStock(self,sortkey,asc_flag,page):
        page = str(page)
        del vim.current.buffer[:]
        cur_url = self.get_url(sortkey,asc_flag,page)
        r = requests.get(cur_url)
        df = pd.read_html(r.text)[0]
        df.columns = ['a', 'b', 'c', 'd', 'e','f', 'g', 'h', 'i', 'j','k', 'l', 'm', 'n', 'o']
        del df['o']
        df = df.set_index('a')
        #print df
        vim.current.buffer.append('      代码     名称     现价  涨跌幅(%) 涨跌   涨速(%) 换手(%)  量比   振幅(%)    成交额       流通股       流通市值    市盈率  ')
        vim.current.buffer.append('')
        numList = df.index.values
        for i in numList:
            num = i
            stockCode = df.get_value(i,'b')
            stockName = df.get_value(i,'c')
            price      = df.get_value(i,'d')
            zdf       = df.get_value(i,'e')
            zd        = df.get_value(i,'f')
            zs        = df.get_value(i,'g')
            hs      = df.get_value(i,'h')
            lb      = df.get_value(i,'i')
            zf      = df.get_value(i,'j')
            cje      = df.get_value(i,'k')
            ltg      = df.get_value(i,'l')
            tlsz      = df.get_value(i,'m')
            syl      = df.get_value(i,'n')
            vim.current.buffer.append('%+2s  %+6s  %+4s  %+6s  %+6s  %+6s  %+6s  %+6s  %+6s  %+6s  %+10s  %+10s  %+10s  %+8s'%(num,stockCode,stockName,price,zdf,zd,zs,hs,lb,zf,cje,ltg,tlsz,syl))
            #self.title_print2()
            #print tabulate(df, tablefmt='rst')
        vim.current.buffer.append('')
        cmdStr = 'Vallstock '+sortkey+' '+asc_flag+' '+page
        vim.current.buffer.append(cmdStr)


################################################################################################################
#
#        
#                                获得资金信息，包括个股资金流，概念版本，行业版本
#
#
################################################################################################################
class FundsInfo():
    

    ########################
    #    获得个股资金流
    ########################
    def get_ggzjl(self,sortkey,asc_flag,page):

        field_ggzjl = {'je':'zjjlr','zdf':'zdf','lrzj':'flowin','lczj':'flowout','cje':'money','ddlr':'ddlr'}
        page = str(page)
        asc = 'desc'
        if asc_flag is '0':
            asc = 'asc'

        orderKey = field_ggzjl[sortkey]
        cur_url = 'http://data.10jqka.com.cn/funds/ggzjl/field/'+orderKey+'/order/'+asc+'/page/'+page+'/ajax/1/'
        r = requests.get(cur_url)
        df = pd.read_html(r.text)[0]

        self.__output_gg__(df)

        vim.current.buffer.append('')
        cmdStr = 'Vggzjl '+sortkey+' '+asc_flag+' '+page
        vim.current.buffer.append(cmdStr)


    ########################
    #    获得概念啊资金流
    ########################
    def get_gnzjl(self,sortkey,asc_flag,page):

        field_gnzjl = {'je':'je','zdf':'tradezdf','lrzj':'buy','lczj':'sell'}
        page = str(page)
        asc = 'desc'
        if asc_flag is '0':
            asc = 'asc'

        orderKey = field_gnzjl[sortkey]
        cur_url = 'http://data.10jqka.com.cn/funds/gnzjl/field/'+orderKey+'/order/'+asc+'/page/'+page+'/ajax/1/'
        r = requests.get(cur_url)
        df = pd.read_html(r.text)[0]
        df['z'] = self.__get_bk_codes__(r.text)
        self.__output_gn__(df)

        vim.current.buffer.append('')
        cmdStr = 'Vgnzjl '+sortkey+' '+asc_flag+' '+page
        vim.current.buffer.append(cmdStr)


    ########################
    #    获得行业资金流
    ########################
    def get_hyzjl(self,sortkey,asc_flag,page):

        field_hyzjl = {'je':'je','zdf':'tradezdf','lrzj':'buy','lczj':'sell'}
        page = str(page)
        asc = 'desc'
        if asc_flag is '0':
            asc = 'asc'

        orderKey = field_hyzjl[sortkey]
        cur_url = 'http://data.10jqka.com.cn/funds/hyzjl/field/'+orderKey+'/order/'+asc+'/page/'+page+'/ajax/1/'
        r = requests.get(cur_url)
        df = pd.read_html(r.text)[0]
        df['z'] = self.__get_bk_codes__(r.text)
        
        self.__output_hy__(df)

        vim.current.buffer.append('')
        cmdStr = 'Vhyzjl '+sortkey+' '+asc_flag+' '+page
        vim.current.buffer.append(cmdStr)

    ########################
    #    获取板块信息
    ########################
 
    def get_bk(self,code,desc,page):

    #line = vim.current.buffer[vim.current.window.cursor[0]-1]
    #url = re.findall('<h>(.*?)<h>',line,re.S|re.M)[0]
        url = ''
        if code[0] is '8':
            url = 'http://q.10jqka.com.cn/thshy/detail/field/199112/order/desc/page/'+page+'/ajax/1/code/'+code
        else :
            url = 'http://q.10jqka.com.cn/gn/detail/field/199112/order/desc/page/'+page+'/ajax/1/code/'+code
        r = requests.get(url)
        df = pd.read_html(r.text)[0]
        self.__output_bk__(df)
        vim.current.buffer.append('')
        cmdStr = 'Vbk '+code+' 1'+' '+page
        vim.current.buffer.append(cmdStr)

    def get_bk_quick(self):
        
        line = vim.current.buffer[vim.current.window.cursor[0]-1]
        code = re.findall('<(.*?)>',line,re.S|re.M)[0]
        self.get_bk(code,'1','1')

    ########################
    #   得到板块的链接 
    ########################    
    def __get_bk_codes__(self,text):
        url_arr = []
        tbody = re.findall('<tbody>(.*?)</tbody>',text,re.S|re.M)
        tr = re.findall('<tr(.*?)</tr>',tbody[0],re.S|re.M)
        for line in tr:
            urls = re.findall("(?<=href=\").+?(?=\")|(?<=href=\').+?(?=\')",line,re.S|re.M)
            url =  urls[0]
            code = url[-7:-1]
            code = '<'+code+'>'
            #code = re.findall('/(.*?)/<h>',url,re.S|re.M)
            url_arr.append(code)
        return url_arr



    ########################
    #    个股资金流输出
    ########################    
    def __output_gg__(self,df):
        df.columns = ['a', 'b', 'c', 'd', 'e','f', 'g', 'h', 'i', 'j','k']
        df = df.set_index('a')
    	del vim.current.buffer[:]
        vim.current.buffer.append('     代码       名称     最新价    涨跌幅   换手率    流入资金(元)  流出资金(元)   净额(元)     成交额(元)   大单流入(元)  ')

        vim.current.buffer.append('')
        numList = df.index.values
        for i in numList:
            f0  = i
            f1  = df.get_value(i,'b')
            f2  = df.get_value(i,'c')
            f3  = df.get_value(i,'d')
            f4  = df.get_value(i,'e')
            f5  = df.get_value(i,'f')
            f6     = df.get_value(i,'g')
            f7    = df.get_value(i,'h')
            f8    = df.get_value(i,'i')
            f9    = df.get_value(i,'j')
            f10    = df.get_value(i,'k')

            vim.current.buffer.append('%+2s  %+6s  %+6s   %+6s    %+6s   %+6s   %+10s   %+10s   %+10s   %+10s   %+10s'%(f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10))



    ########################
    #   行业资金流输出
    ########################
    def __output_bk__(self,df):
        
        df.columns = ['a', 'b', 'c', 'd', 'e','f', 'g', 'h', 'i', 'j','k','l','m','n','o']
        del df['o']
        df = df.set_index('a')
    	del vim.current.buffer[:]
        vim.current.buffer.append('      代码     名称     现价  涨跌幅(%) 涨跌   涨速(%) 换手(%)  量比   振幅(%)    成交额       流通股       流通市值    市盈率  ')
        vim.current.buffer.append('')
        numList = df.index.values
        for i in numList:
            num = i
            stockCode = df.get_value(i,'b')
            stockName = df.get_value(i,'c')
            price      = df.get_value(i,'d')
            zdf       = df.get_value(i,'e')
            zd        = df.get_value(i,'f')
            zs        = df.get_value(i,'g')
            hs      = df.get_value(i,'h')
            lb      = df.get_value(i,'i')
            zf      = df.get_value(i,'j')
            cje      = df.get_value(i,'k')
            ltg      = df.get_value(i,'l')
            tlsz      = df.get_value(i,'m')
            syl      = df.get_value(i,'n')
            vim.current.buffer.append('%+2s  %+6s  %+4s  %+6s  %+6s  %+6s  %+6s  %+6s  %+6s  %+6s  %+10s  %+10s  %+10s  %+8s'%(num,stockCode,stockName,price,zdf,zd,zs,hs,lb,zf,cje,ltg,tlsz,syl))
   
    ########################
    #   行业资金流输出
    ########################
    def __output_hy__(self,df):
        df.columns = ['a', 'b', 'c', 'd', 'e','f', 'g', 'h', 'i', 'j','k','z']
        df = df.set_index('a')
    	del vim.current.buffer[:]
        vim.current.buffer.append('       行业     代码    涨跌幅  行业指数    流入资金(亿)   流出资金(亿)  净额(亿)  公司家数   领涨股   涨跌幅.1  当前价(元)')
        vim.current.buffer.append('')
        
        numList = df.index.values
        for i in numList:
            f0  = i
            f1  = df.get_value(i,'b')
            f2  = df.get_value(i,'c')
            f3  = df.get_value(i,'d')
            f4  = df.get_value(i,'e')
            f5  = df.get_value(i,'f')
            f6     = df.get_value(i,'g')
            f7    = df.get_value(i,'h')
            f8    = df.get_value(i,'i')
            f9    = df.get_value(i,'j')
            f10    = df.get_value(i,'k')
            f11   = df.get_value(i,'z')

            vim.current.buffer.append('%+2s  %+6s  %+8s  %+6s  %+8s     %+6s      %+6s     %+6s     %+4s      %+4s    %+6s    %+6s  '%(f0,f1,f11,f3,f2,f4,f5,f6,f7,f8,f9,f10))

    ########################
    #    概念，资金流输出
    ########################
    def __output_gn__(self,df):
        df.columns = ['a', 'b', 'c', 'd', 'e','f', 'g', 'h', 'i', 'j','k','z']
        df = df.set_index('a')
    	del vim.current.buffer[:]
        vim.current.buffer.append('       行业     代码    涨跌幅  行业指数    流入资金(亿)   流出资金(亿)  净额(亿)  公司家数   领涨股   涨跌幅.1  当前价(元)')
        vim.current.buffer.append('')
        
        numList = df.index.values
        for i in numList:
            f0  = i
            f1  = df.get_value(i,'b')
            f2  = df.get_value(i,'c')
            f3  = df.get_value(i,'d')
            f4  = df.get_value(i,'e')
            f5  = df.get_value(i,'f')
            f6     = df.get_value(i,'g')
            f7    = df.get_value(i,'h')
            f8    = df.get_value(i,'i')
            f9    = df.get_value(i,'j')
            f10    = df.get_value(i,'k')
            f11   = df.get_value(i,'z')

            vim.current.buffer.append('%+2s  %+6s  %+8s  %+6s  %+8s     %+6s      %+6s     %+6s     %+4s      %+4s    %+6s    %+6s  '%(f0,f1,f11,f3,f2,f4,f5,f6,f7,f8,f9,f10))



################################################################################################################
#
#       
#                               获得资金信息，包括个股资金流，概念版本，行业版本
#
#
################################################################################################################
class MiniStock():


    ########################
    #   自动运行
    ########################    
    def autorun(self):
        
        vim.command('new')
        vim.current.window = vim.windows[0]
        vim.command('vnew')
        vim.command('vnew')
        
        index = 0
        cmdStr = ['Vallstock zs True 1','Vgnzjl zdf True 1','Vhyzjl zdf True 1','Vallstock zdf True 1']
        for w in vim.windows:
            vim.current.window = w
            vim.command(cmdStr[index])
            index = index + 1

    def refresh(self):
        cmdStr = vim.current.buffer[-1]
        #vim.current.buffer.append(cmdStr)
        vim.command(cmdStr)
        
    def refresh_all(self):
        for w in vim.windows:
            cmdStr = w.buffer[-1]
            vim.current.window = w
            vim.command(cmdStr)
            
    def Next_page(self):
        cmdStr = vim.current.buffer[-1]
        strArr = cmdStr.split()
        page = str(int(strArr[3])+1)
        vim.command(strArr[0]+' '+strArr[1]+' '+strArr[2]+' '+page)
        
    def pre_page(self):
        cmdStr = vim.current.buffer[-1]
        strArr = cmdStr.split()
        page = strArr[3]
        if int(strArr[3])>1:
            page = str(int(strArr[3])-1)
        vim.command(strArr[0]+' '+strArr[1]+' '+strArr[2]+' '+page)
        
    def enter(self):
        cmds = ['Vgo']
        cmdStr = vim.current.buffer[-1]
        strArr = cmdStr.split()
        cmd = strArr[0]

        if cmd is cmds[0]:
            fi = FundsInfo()
            fi.get_bk_quick()
        

################################################################################################################
#
#       
#                               命令封装
#
#
################################################################################################################

class CMD_Package():

    all_stock = TotalStockInfo()
    zjl = FundsInfo()

    def get_zdf(self):
        self.all_stock.GetStock("zdf","1","1")
    def get_zdfd(self):
        self.all_stock.GetStock("zdf","0","1")

    def get_zs(self):
        self.all_stock.GetStock("zs","1","1")
    def get_zsd(self):
        self.all_stock.GetStock("zs","0","1")

    def get_hs(self):
        self.all_stock.GetStock("hs","1","1")
    def get_hsd(self):
        self.all_stock.GetStock("hs","0","1")

    def get_dde(self):
        self.zjl.get_ggzjl("ddlr","1","1")
    def get_dded(self):
        self.zjl.get_ggzjl("ddlr","0","1")

    def get_gn(self):
        self.zjl.get_gnzjl("zdf","1","1")
    def get_gnd(self):
        self.zjl.get_gnzjl("zdf","0","1")

    def get_hy(self):
        self.zjl.get_hyzjl("zdf","1","1")
    def get_hyd(self):
        self.zjl.get_hyzjl("zdf","0","1")



EOF

