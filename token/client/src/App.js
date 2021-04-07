import React, {useState, useEffect} from "react"
import './App.css'
import {getWeb3} from "./getWeb3"
import map from "./artifacts/deployments/map.json"
import {getEthereum} from "./getEthereum"


function App() {
    const [state, setState] = useState({
        web3: null,
        accounts: null,
        chainId: null,
    })
    const [shrubManager, setShrubManager] = useState(null);
    const [shrubManagerProperties, setShrubManagerProperties] = useState(null)
    const loadContract = async (chain, contractName, deploymentNum = 0) => {
      const {web3} = state;
      if (!web3) {
          return null;
      }
  
      // Get the address of the most recent deployment from the deployment map
      let address;
      try  {
        address = map[chain][contractName][deploymentNum];
      } catch(e) {
          console.log(`Couldn't find any deployed contract "${contractName}" on the chain "${chain}".`);
          return null;
      }

      // Load the artifact with the specified address

     let contractArtifact;
      try  {
        contractArtifact = await import(`./artifacts/deployments/${chain}/${address}.json`);
      } catch(e) {
        console.log(`Failed to load contract artifact "./artifacts/deployments/${chain}/${address}.json"`);
          return null;
      }

      return new web3.eth.Contract(contractArtifact.abi, address);
    }

    async function init() {
      const web3 = await getWeb3();
        // Try and enable accounts (connect metamask)
     try {
      const ethereum = await getEthereum()
      ethereum.enable()

     } catch (err) {
         console.log(err)
     }
        // Use web3 to get the user's accounts
      const accounts = await web3.eth.getAccounts()

      // Get the current chain id
      const chainId = parseInt(await web3.eth.getChainId())
      if (chainId <= 42) {
          // Wrong Network!
          return
      }  
      setState({web3, accounts, chainId})
      
    }
    useEffect(() => {
        init();
    }, []);

    useEffect(() => {
        if (state.web3) {
          loadContract("dev", "ShrubManager").then(async (contract) => {
          if (contract) {
          setShrubManager(contract);
          populateShrubManagerProperties(contract);
          }
        }
       );

      }
    }, [state.web3, state.accounts, state.chainId])

    async function getContractProperty(contract, propName) {
        const value = await contract.methods[propName]().call();
        return value;
    }

    async function populateShrubManagerProperties(contract) {
        const tokenPrice = await getContractProperty(contract, 'tokenPrice');
        const tokensSold = await getContractProperty(contract, 'tokensSold');
        const state = await getContractProperty(contract, 'state');
        const test = await getContractProperty(contract, 'test');
        setShrubManagerProperties({
            tokenPrice,
            tokensSold,
            state,
            test,
        })
    }
    const isAccountsUnlocked = state.accounts ? state.accounts.length > 0 : false;
    return (
        <div className="App">
          {!isAccountsUnlocked ? (
            <p><strong>Connect with Metamask and refresh the page.</strong>
            </p>
          ) : shrubManagerProperties ? (
            <ShrubManager shrubManagerProperties={shrubManagerProperties} />
          ) : (
            <div>Loading <code>ShrubManager</code> ...</div>
          )

          }
        </div>
    )
}

const ShrubManager = ({shrubManagerProperties: {tokenPrice, tokensSold, state, test}}) => {
    return (
      <ul>
        <li>Token Price: {tokenPrice}</li>
        <li>Tokens sold: {tokensSold}</li>
        <li>State: {state}</li>
        <li>Test: {test}</li>
      </ul>
    )
}
export default App
