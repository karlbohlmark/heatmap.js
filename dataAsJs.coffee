main = ()->
    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    data = ''
    process.stdin.on 'data', (chunk) -> data+=chunk
    process.stdin.on 'end', () -> 
        process.stdout.write( 'var data=' + data + ';')

main() if not module.parent