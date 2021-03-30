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
    const loadContract = async (chain, contractName, deployment = 0) => {
      const {web3} = state;
      if (!web3) {
          return null;
      }
  
      // Get the address of the most recent deployment from the deployment map
      const address = map[chain][contractName][deployment]

      // Load the artifact with the specified address
      const contractArtifact = await import(`./artifacts/deployments/${chain}/${address}.json`)

      if (!address || !contractArtifact) {
          return null;
      }
  
      return new web3.eth.Contract(contractArtifact.abi, address)
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
        getShrubManager()

        }
    }, [state.web3])

    async function getShrubManager() {
        loadContract("dev", "ShrubManager").then(async (contract) => {
            setShrubManager(contract)
            populateShrubManagerProperties(contract);
            }
        );
    }

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
    return (
        <div className="App">
          {shrubManagerProperties ? (
            <ul>
              <li>Token Price: {shrubManagerProperties.tokenPrice}</li>
              <li>Tokens sold: {shrubManagerProperties.tokensSold}</li>
              <li>State: {shrubManagerProperties.state}</li>
              <li>Test: {shrubManagerProperties.test}</li>
            </ul>
          ) : (
            <div>Loading <code>ShrubManager</code> ...</div>
          )

          }
        </div>
    )
}

export default App
