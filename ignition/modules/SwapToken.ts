import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SwapTokenModule = buildModule("SwapTokenModule", (m) => {
  const bstToken = m.contract("BaseToken", ["0xD1f4c4AFFfbc6984214d37bef1e3153b911e5166"]);

  const dollarToken = m.contract("UsdtToken", ["0xD1f4c4AFFfbc6984214d37bef1e3153b911e5166"]);

  const swap = m.contract("SwapToken", [bstToken, dollarToken]);



  return { swap };
});

export default SwapTokenModule;

