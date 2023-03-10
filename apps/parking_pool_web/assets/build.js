/**
 * https://hexdocs.pm/phoenix/asset_management.html
 */
const esbuild = require('esbuild')

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const loader = {
    // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
}

let sveltePlugin = {
    name: 'svelte',
    setup(build) {
        let svelte = require('svelte/compiler')
        let path = require('path')
        let fs = require('fs')

        build.onLoad({ filter: /\.svelte$/ }, async (args) => {
            // This converts a message in Svelte's format to esbuild's format
            let convertMessage = ({ message, start, end }) => {
                let location
                if (start && end) {
                    let lineText = source.split(/\r\n|\r|\n/g)[start.line - 1]
                    let lineEnd = start.line === end.line ? end.column : lineText.length
                    location = {
                        file: filename,
                        line: start.line,
                        column: start.column,
                        length: lineEnd - start.column,
                        lineText,
                    }
                }
                return { text: message, location }
            }

            // Load the file from the file system
            let source = await fs.promises.readFile(args.path, 'utf8')
            let filename = path.relative(process.cwd(), args.path)

            // Convert Svelte syntax to JavaScript
            try {
                let { js, warnings } = svelte.compile(source, { filename })
                let contents = js.code + `//# sourceMappingURL=` + js.map.toUrl()
                return { contents, warnings: warnings.map(convertMessage) }
            } catch (e) {
                return { errors: [convertMessage(e)] }
            }
        })
    }
}

const plugins = [
    sveltePlugin,
    // Add and configure plugins here
]

let opts = {
    entryPoints: ['js/app.js'],
    bundle: true,
    target: 'es2017',
    outdir: '../priv/static/assets',
    logLevel: 'info',
    loader,
    plugins
}

if (watch) {
    opts = {
        ...opts,
        watch,
        sourcemap: 'inline'
    }
}

if (deploy) {
    opts = {
        ...opts,
        minify: true
    }
}

const promise = esbuild.build(opts)

if (watch) {
    promise.then(_result => {
        process.stdin.on('close', () => {
            process.exit(0)
        })

        process.stdin.resume()
    })
}
