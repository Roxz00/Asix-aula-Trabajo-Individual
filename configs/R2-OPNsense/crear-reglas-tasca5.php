<?php
// Tasca 5: dos reglas en el modelo nuevo de reglas de OPNsense (MVC), delante de la regla por defecto de la LAN
$doc = new DOMDocument(); $doc->preserveWhiteSpace = false; $doc->load('/conf/config.xml');
$xp = new DOMXPath($doc);
$def = $xp->query('//Firewall/Filter/rules/rule[@uuid="019cd9b3-bcea-4560-a1d5-7372934acd0f"]')->item(0);
function uuid4() { $d = random_bytes(16); $d[6] = chr(ord($d[6]) & 0x0f | 0x40); $d[8] = chr(ord($d[8]) & 0x3f | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($d), 4)); }
function nueva($def, $campos) {
    $r = $def->cloneNode(true); $r->setAttribute('uuid', uuid4());
    foreach ($campos as $k => $v) { $n = $r->getElementsByTagName($k)->item(0); $n->nodeValue = $v; }
    return $r;
}
$bloq = nueva($def, ['sequence'=>'10','action'=>'block','protocol'=>'TCP/UDP','destination_net'=>'172.16.222.1',
    'destination_not'=>'1','destination_port'=>'53','log'=>'1','description'=>'Tasca 5: DNS externo bloqueado']);
$http = nueva($def, ['sequence'=>'20','action'=>'pass','protocol'=>'TCP','destination_port'=>'80','log'=>'1',
    'description'=>'Tasca 5: HTTP permitido y registrado']);
$def->getElementsByTagName('sequence')->item(0)->nodeValue = '100';
$def->parentNode->insertBefore($bloq, $def); $def->parentNode->insertBefore($http, $def);
$doc->formatOutput = true; $doc->save('/conf/config.xml');
echo "reglas MVC añadidas\n";
