import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SwapModule = buildModule("SwapModule", (m) => {
  const ngnToken = m.contract("NairaToken", ["0xD1f4c4AFFfbc6984214d37bef1e3153b911e5166"]);

  const dollarToken = m.contract("UsdtToken", ["0xD1f4c4AFFfbc6984214d37bef1e3153b911e5166"]);

  const swap = m.contract("SwapToken", [ngnToken, dollarToken]);



  return { swap };
});

export default SwapModule;