declare module 'fairy-stockfish-web' {
  interface FairyStockfishWeb {
    postMessage(uci: string): void;
    listen: (data: string) => void; // attach listener here
    setNnueBuffer(data: Uint8Array): void;
    getRecommendedNnue(): string; // returns a bare filename
    onError: (msg: string) => void; // attach error handler here
  }
  export default FairyStockfishWeb;
}
