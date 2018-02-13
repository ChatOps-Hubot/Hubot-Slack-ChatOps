###
    Script that map with XLSX

    input : Excel File
    output: query String for the database
###

module.exports = (robot) ->
    robot.respond /(.*)/i, (res) ->
        # console.log (res.match)
        filepath = '.\\xls' + '\\dbQuery.xlsx'
        file=require('xlsjs').readFile(filepath)
        param = res.match[1].replace /^\s+|\s+$/g, ""
        params = []
        console.log(param)
        # command_str = file.Strings[0].t
        # query_str = file.Strings[1].t
        # mrg_str = qury_str.replace '{{ref_text}}',res.match[1]
        
        console.log(file.Strings)
        cnt = 0
        while cnt < file.Strings.Count
            # console.log cnt
          
            regex = file.Strings[cnt].t.toLowerCase() + ' '
            strString = res.match[0].toLowerCase()
            # console.log(strString)
            # console.log(regex)
            strCount = strString.search regex
            # console.log strCount

            if strCount == -1
                cnt = cnt + 2
            else
                index = cnt + 1
                # console.log (index)
                query_str= file.Strings[index].t
                break

        console.log(query_str)
        if query_str == undefined
            res.send 'No Keyword Found'
        else            
            params_index = param.indexOf " "
            console.log(params_index)
            param_str = param.substr params_index
            param_str = param_str.replace /^\s+|\s+$/g, ""
            console.log(param_str)
            # console.log (param_str.indexOf " ")
            searchResult = param_str.indexOf " "
            if  searchResult > 0
                console.log 1
                def = param_str.split " "
                params = def.filter (x) -> x != (undefined || null || '')
            else   
                console.log 2               
                params[0] = param_str     

            console.log(params)
            mrg_str = query_str.replace /{{ref_text}}/, params[0]
            # console.log(mrg_str)
            console.log encodeURIComponent mrg_str
            res.send mrg_str