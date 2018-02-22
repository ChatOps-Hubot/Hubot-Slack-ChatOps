###
    Script that map with XLSX

    input : Excel File
    output: query String for the database
###

module.exports = (robot) ->
    robot.respond /(.*)/i, (res) ->
        # console.log (res.match)
        fpath = '.\\xls' + '\\configData.xlsx'
        configFile fpath,'Type', 'connection'

        filepath = '.\\xls' + '\\dbQuery.xlsx'
        file=require('xlsjs').readFile(filepath)
        param = res.match[1].replace /^\s+|\s+$/g, ""        
        params = []
        console.log 'Param : ' + param

        
        ### check db Connection Configration Available or not ###
         
        connfilepath = '.\\xls' + '\\dbConnection.xlsx'
        connfile=require('xlsjs').readFile(connfilepath)
        # console.log connfile.Sheets.Sheet1['B1']['v']   
        findConn = param.split(" ");
        Branch = ''
        cnt = 0
        col = 1
        console.log 'count : ' + connfile.Strings.Count
        while cnt < connfile.Strings.Count
            # console.log cnt
            sheetCol  =  'A' + col  
            console.log sheetCol  
            regex = connfile.Sheets.Sheet1[sheetCol]['v'].toLowerCase() + ' '
            strString = res.match[0].toLowerCase()
            console.log(strString)
            console.log(regex)
            strCount = strString.search regex
            console.log strCount

            if strCount == -1
                cnt = cnt + 7
                col = col + 1
            else
                queryCol = 'E' + col 
                # console.log (index)
                conn_query_str= connfile.Sheets.Sheet1[queryCol]['v']
                break

        # console.log(query_str)
        if conn_query_str == undefined
            res.send 'No Database Connection Found'
        else 
            dbBranch = findConn[0]   

            ####  End  Connection Configration  ###

            # console.log('-------------')
            # console.log(file.Sheets.Sheet1)
            # console.log('-------------')
            # command_str = file.Strings[0].t
            # query_str = file.Strings[1].t
            # mrg_str = qury_str.replace '{{ref_text}}',res.match[1]
            console.log '-----------------------'
            console.log(file.Strings)
            cnt = 0
            col = 1
            while cnt < file.Strings.Count
                # console.log cnt
                sheetCol  =  'A' + col    
                regex = file.Sheets.Sheet1[sheetCol].v.toLowerCase() + ' '
                strString = findConn[1].toLowerCase() + ' '
                # console.log(strString)
                # console.log(regex)
                strCount = strString.search regex
                # console.log strCount

                if strCount == -1
                    cnt = cnt + 2
                    col = col + 1
                else
                    queryCol = 'B' + col 
                    # console.log (index)
                    query_str= file.Sheets.Sheet1[queryCol].v
                    break

            # console.log(query_str)
            if query_str == undefined
                res.send 'No Keyword Found'
            else            
                param = param.substr param.indexOf " "
                param = param.replace /^\s+|\s+$/g, ""
                console.log 'Param String : ' + param
                params_index = param.indexOf " "
                console.log(params_index)
                param_str = param.substr params_index
                param_str = param_str.replace /^\s+|\s+$/g, ""
                # console.log(param_str)
                # console.log (param_str.indexOf " ")
                searchResult = param_str.indexOf " "
                if  searchResult > 0
                    console.log 1
                    def = param_str.split " "
                    params = def.filter (x) -> x != (undefined || null || '')
                else   
                    console.log 2               
                    params[0] = param_str     

                # console.log(params)
                shortCountry=params[0]
                # mrg_str = query_str.replace /{{ref_text}}/, params[0]
                mrg_str = makeQuery params, query_str
                console.log 'query : ' + mrg_str
                result =  encodeURIComponent mrg_str           
                # res.send getFunction result
                rtStr = getFunction result
                geturl = "http://localhost:8083/query/"+ dbBranch + "/" + rtStr
                console.log 'URL : ' + geturl
                robot.http(geturl)            
                .get() (err, response, body) ->
                    # console.log body
                    data = JSON.parse body
                    # console.log(data)             
                    if data.recordset.length > 0
                        # res.send data.recordset[0].countrydesc 
                        fs = require('fs')
                        filepath = '.\\File' + '\\' + shortCountry + '.txt'
                        fs.writeFile filepath, JSON.stringify(data.recordset[0]), (error) ->
                            if(error)
                                console.log('error in file')
                                res.send 'File is not Created for ' + shortCountry 
                            else    
                                console.log('file created')
                                # console.log(Object.keys(data.recordset[0]))
                                keys = Object.keys(data.recordset[0])
                                template = ''
                                for k,v of data.recordset[0]
                                    template = template + k + ' : ' + v + '\n'
                                # console.log template                                
                                res.send template + '\nFile is Created for ' + shortCountry 
                    
                    else
                        res.send "No Data Found"

    getFunction = (Options) ->
          chars = {"'" : "%27", "(" : "%28" ,")" : "%29","*" : "%2A","!" : "%21","~" : "%7E"}
          Options.replace /[~!*()']/g,  (m)  => chars[m]          
    
    makeQuery = (data, changeStr) ->
        console.log 'old : ' + changeStr
        cnt = 0
        
        while cnt < data.length
            if cnt > 0 
                refstr= '{{ref_text' + cnt + '}}'
            else
                refstr= '{{ref_text}}'
            # console.log refstr
            # console.log data[cnt]
            changeStr = changeStr.replace refstr , data[cnt]
            cnt++
        console.log 'new : ' + changeStr
        return changeStr

    configFile = (filepath, field, fvalue) ->
        console.log 'In ConfigFile Funciton'
        #fpath = '.\\xls' + '\\configData.xlsx'
        XLSX  = require ('xlsx') 
        workbook = XLSX.readFile(filepath)
        sheet_name_list = workbook.SheetNames

        for k,v in sheet_name_list
            console.log k + ' ' + v
            worksheet =  workbook.Sheets[k]
            ref = '!ref'

            console.log worksheet['!ref']
            range = worksheet['!ref'].split ":"
            console.log range

            x= range[0]
            y = range[1]

            stAlpc = x.replace /[!^0-9\.]/g, ''
            spAlpc = y.replace /[!^0-9\.]/g, ''

            stNum = x.replace /[^0-9\.]/g, ''
            spNum = y.replace /[^0-9\.]/g, ''

            stAlp = stAlpc.charCodeAt 0
            spAlp = spAlpc.charCodeAt 0

            console.log stAlp + ' ' + spAlp + ' ' + stNum + ' ' + spNum

            headers = {}
            data = []
            xlsData = {} 
            for z in [stAlp..spAlp]
                for x in [stNum..spNum]
                    # console.log String.fromCharCode(z) + ' ' + x
                    row = x
                    col = String.fromCharCode(z)
                    sheetcell = col + row
                    console.log worksheet[sheetcell]
                    if worksheet[sheetcell] == undefined
                        continue
                    else
                        value = worksheet[sheetcell].v

                    console.log col + ' ' + row + ' ' + value

                    if row == 1
                        headers[col] = value
                        continue

                    if !data[row] 
                        data[row] = {}
                
                data[row][headers[col]] = value
                
            data.shift()
            data.shift()

            console.log 'config Data -> ' + JSON.stringify data

            xlsData = data.find (x) -> 
                
                if field == 'Type'
                    return x.Type == fvalue
                
                if field == 'Branch'
                    return x.BranchID == fvalue

            console.log 'xls ---->' + xlsData
            
            return xlsData