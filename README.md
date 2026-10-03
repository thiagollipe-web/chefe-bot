# Chef-Bot — IA Local

O repositorio foi convertido para uma versao web do Chef-Bot com 40 receitas, busca local e interpretacao opcional por SmolLM2 no navegador.

## Teste local
npm install
npm run dev

## GitHub Pages
O projeto e estatico e pode ser publicado pela raiz da branch main.

## IA local
O primeiro carregamento precisa baixar a biblioteca e os pesos do modelo. Depois o cache do navegador pode permitir uso sem rede. WebGPU e tentado primeiro e WASM e o fallback.