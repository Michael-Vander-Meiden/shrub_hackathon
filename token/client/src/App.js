import React, {Component} from "react"
import './App.css'
import {getWeb3} from "./getWeb3"
import map from "./artifacts/deployments/map.json"
import {getEthereum} from "./getEthereum"

import 'bootstrap/dist/css/bootstrap.min.css'

import {Button, Container, Card, Alert, Form} from "react-bootstrap"


class App extends Component {

    state = {
        web3: null,
        accounts: null,
        chainid: null,
        tokenA: null,
        tokenB: null,
        tokenStable: null,
        tokenSupply: 0,
        userBalanceA: null,
        managerState: null,
        numberTokens: 0,
        tokenPrice: 0,
        numToRedeem: 0,
        // vyperStorage: null,
        // vyperValue: 0,
        // vyperInput: 0,
        // solidityStorage: null,
        // solidityValue: 0,
        // solidityInput: 0,
    }

    componentDidMount = async () => {

        // Get network provider and web3 instance.
        const web3 = await getWeb3()

        // Try and enable accounts (connect metamask)
        try {
            const ethereum = await getEthereum()
            ethereum.enable()
        } catch (e) {
            console.log(`Could not enable accounts. Interaction with contracts not available.
            Use a modern browser with a Web3 plugin to fix this issue.`)
            console.log(e)
        }

        // Use web3 to get the user's accounts
        const accounts = await web3.eth.getAccounts()

        // Get the current chain id
        const chainid = parseInt(await web3.eth.getChainId())

        this.setState({
            web3,
            accounts,
            chainid
        }, await this.loadInitialContracts)

    }

    loadInitialContracts = async () => {
        if (this.state.chainid != 4) {
            // Wrong Network!
            return
        }

        //TODO Manually build map.json for correct tokens
        const tokenA = await this.loadContract(4, "TokenA")
        const tokenB = await this.loadContract(4, "TokenB")
        const tokenStable = await this.loadContract(4, "StableCoin")
        const Manager = await this.loadContract(4, "Manager")

        // if (!vyperStorage || !solidityStorage) {
        //     return
        // }
        console.log(tokenA)
        const tokenSupply = await tokenA.methods.totalSupply().call()
        const tokenPrice = await Manager.methods.tokenPrice().call()
        // const vyperValue = await vyperStorage.methods.get().call()
        // const solidityValue = await solidityStorage.methods.get().call()

        const userBalanceA = await tokenA.methods.balanceOf(this.state.accounts[0]).call()
        const userBalanceB = await tokenB.methods.balanceOf(this.state.accounts[0]).call()
        const userBalanceStable = await tokenStable.methods.balanceOf(this.state.accounts[0]).call()


        const managerState = await Manager.methods.state().call()

        this.setState({
            tokenA,
            tokenB,
            tokenStable,
            tokenSupply,
            userBalanceA,
            userBalanceB,
            userBalanceStable,
            Manager,
            managerState,
            tokenPrice,
        })
    }

    loadContract = async (chain, contractName) => {
        // Load a deployed contract instance into a web3 contract object
        const {web3} = this.state

        // Get the address of the most recent deployment from the deployment map
        let address
        try {
            address = map[chain][contractName][0]
        } catch (e) {
            console.log(`Couldn't find any deployed contract "${contractName}" on the chain "${chain}".`)
            return undefined
        }

        // Load the artifact with the specified address
        let contractArtifact
        try {
            contractArtifact = await import(`./artifacts/deployments/${chain}/${address}.json`)
        } catch (e) {
            console.log(`Failed to load contract artifact "./artifacts/deployments/${chain}/${address}.json"`)
            return undefined
        }

        return new web3.eth.Contract(contractArtifact.abi, address)
    }

    changeVyper = async (e) => {
        const {accounts, vyperStorage, vyperInput} = this.state
        e.preventDefault()
        const value = parseInt(vyperInput)
        if (isNaN(value)) {
            alert("invalid value")
            return
        }
        await vyperStorage.methods.set(value).send({from: accounts[0]})
            .on('receipt', async () => {
                this.setState({
                    vyperValue: await vyperStorage.methods.get().call()
                })
            })
    }

    redeemTokens = async (e) => {
        const {accounts, Manager, numberTokens, tokenA, tokenPrice} = this.state
        e.preventDefault()
        await Manager.methods.redeem().send({from: accounts[0], gas: 3000000})
            .on('receipt', async () => {
                this.setState({
                    userBalanceA: await tokenA.methods.balanceOf(this.state.accounts[0]).call()
                    
                })
            })
    }


    buyTokens = async (e) => {
        const {accounts, Manager, numberTokens, tokenA, tokenStable, tokenPrice} = this.state
        e.preventDefault()
        const value = parseInt(numberTokens) * tokenPrice
        if (isNaN(value)) {
            alert("invalid value")
            return
        }
        await tokenStable.methods.approve(Manager.options.address, value).send({from: accounts[0], gas: 3000000})
            .on('receipt', async () => {
                Manager.methods.buyTokens(numberTokens).send({from: accounts[0], gas: 3000000, value:value})
                .on('receipt', async () => {
                    this.setState({
                        userBalanceA: await tokenA.methods.balanceOf(this.state.accounts[0]).call()
                        
                    })
                })
            })
         
    }

    render() {
        const {
            web3, accounts, chainid, tokenA, tokenSupply, userBalanceA, userBalanceB, userBalanceStable, managerState, Manager, numberTokens, tokenPrice, numToRedeem
            // vyperStorage, vyperValue, vyperInput,
            // solidityStorage, solidityValue, solidityInput
        } = this.state

        if (!web3) {
            return <div>Loading Web3, accounts, and contracts...</div>
        }

        if (chainid != 4) {
            console.log(chainid)
            return <div>Wrong Network! Switch to your local RPC "Localhost: 8545" in your Web3 provider (e.g. Metamask)</div>
        }

        if (!tokenA) {
            console.log(tokenA)
            return <div>Could not find a deployed contract. Check console for details.</div>
        }

        const isAccountsUnlocked = accounts ? accounts.length > 0 : false

        return (
        <body>
        
        <div className="App">
        

            {
                !isAccountsUnlocked ?
                    <p><strong>Connect with Metamask and refresh the page to
                        be able to edit the storage fields.</strong>
                    </p>
                    : null
            }
            
            <Container>
            
                <br/>
                <div class="row flex-xl-nowrap">
                    <div class="col">
                        <Alert variant="primary">
                            <h1> Shrub Marketplace </h1>
                            <h2>State: {managerState}</h2>
                        </Alert>
                    </div>
                </div>
    
                <div class="row flex-xl-nowrap">
                    <div class="col-7">
                    </div>
                    <div class="col-5">
                    {/* <h2>State {managerState}</h2> */}
                    
                        <Card variant="secondary">
                            <Card.Header>
                                    <h2>Balances</h2>
                            </Card.Header>
                            <Card.Body >
                                <Card.Text>
                                    {/* <div>The total supply is: {tokenSupply}</div> */}
                                    <div>Your <strong>A</strong> Token Balance: {userBalanceA} </div>
                                    <div>Your <strong>B</strong> Token Balance: {userBalanceB} </div>
                                    <div>Your <strong>DAI</strong> Balance: {userBalanceStable} </div>
                                </Card.Text>
                            </Card.Body>
                        </Card>
                    <br/>
                    </div>
                </div>
                <div class="row flex-xl-nowrap">
                    <div class="col-2">
                    </div>
                    <div class="col-8">

                        <Card>
                            <Card.Header>
                                <h2>Purchase Token Pairs</h2>
                            </Card.Header>
                                <br/>
                                <Card.Text>
                                    <h5>Current Price: {tokenPrice} wei per A/B pair of tokens</h5>
                                </Card.Text>
                                <br/>
                            <Form onSubmit={(e) => this.buyTokens(e)}>
                                <Form.Group >
                                
                                    <Form.Label> Number of tokens: </Form.Label>
                                    <div class="row flex-xl-nowrap">
                                        <div class="col-4">
                                        </div>
                                        <div class="col-4">
                                        <Form.Control
                                            name="numberTokens"
                                            type="number"
                                            value={numberTokens}
                                            onChange={(e) => this.setState({numberTokens: e.target.value})}
                                        />
                                        </div>
                                        
                                    
                                        <div class="col-4">
                                        </div>
                                    </div>
                                    <br/>
                                    <Button type="submit" disabled={!isAccountsUnlocked}>Submit</Button>
                                    
                              </Form.Group>  
                            </Form>
                        </Card>
                    </div>
                    <div class="col-2">
                    </div>
                </div>    
                <br/>
                <div class="row flex-xl-nowrap">
                    <div class="col-2">
                    </div>
                    <div class="col-8">
                        <Card>
                            <Card.Header>
                                <h2>Redeem Tokens</h2>
                            </Card.Header>
                            <Form onSubmit={(e) => this.redeemTokens(e)}>
                                    <br/>
                                    <Form.Label><h5>Click here to redeem your tokens: </h5></Form.Label>
                                    
                                    <br/>
                                    
                                    <Button type="submit" disabled={!isAccountsUnlocked}>Redeem Tokens</Button>
                                        
                            </Form>
                            <br/>
                        
                        </Card>
                    
                    </div>
                    <div class="col-2">
                    </div>
                </div>
            
        </Container>
        
        </div>
        </body>)
    }
}

export default App
